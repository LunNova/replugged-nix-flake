{ symlinkJoin
  # This should usually be discord-${discordPathSuffix} but other versions can work
, discord
, replugged
, makeBinaryWrapper
, writeShellScript
, extraElectronArgs ? ""
, discordPathSuffix ? ""
}:
let
  extractCmd = makeBinaryWrapper.extractCmd or (writeShellScript "extract-binary-wrapper-cmd" ''
    strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
  '');
in
symlinkJoin {
  name = "discord-plugged";
  paths = [ discord.out ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    cp -r '${../plugs}' $out/opt/Discord${discordPathSuffix}/resources/app
    substituteInPlace $out/opt/Discord${discordPathSuffix}/resources/app/index.js --replace 'REPLUGGED_SRC' '${replugged}'

    cp -a --remove-destination $(readlink "$out/opt/Discord${discordPathSuffix}/.Discord${discordPathSuffix}-wrapped") "$out/opt/Discord${discordPathSuffix}/.Discord${discordPathSuffix}-wrapped"
    cp -a --remove-destination $(readlink "$out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix}") "$out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix}"

    if grep '\0' $out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix} && wrapperCmd=$(${extractCmd} $out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix}) && [[ $wrapperCmd ]]; then
      # Binary wrapper
      parseMakeCWrapperCall() {
        shift # makeCWrapper
        oldExe=$1; shift
        oldWrapperArgs=("$@")
      }
      eval "parseMakeCWrapperCall ''${wrapperCmd//"${discord.out}"/"$out"}"
      # Binary wrapper
      makeWrapper $oldExe $out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix} "''${oldWrapperArgs[@]}" --add-flags "${extraElectronArgs}"
    else
      # Normal wrapper
      substituteInPlace $out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix} \
      --replace '${discord.out}' "$out" \
      --replace '"$@"' '${extraElectronArgs} "$@"'
    fi

    substituteInPlace $out/opt/Discord${discordPathSuffix}/Discord${discordPathSuffix} --replace '${discord.out}' "$out"
  '';

  meta.mainProgram = if (discord.meta ? mainProgram) then discord.meta.mainProgram else null;
}
