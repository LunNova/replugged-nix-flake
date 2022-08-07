{ symlinkJoin
, discord-canary
, replugged
, makeBinaryWrapper
, writeShellScript
, extraElectronArgs ? ""
}:
let
  extractCmd = makeBinaryWrapper.extractCmd or (writeShellScript "extract-binary-wrapper-cmd" ''
    strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
  '');
in
symlinkJoin {
  name = "discord-plugged";
  paths = [ discord-canary.out ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    cp -r '${../plugs}' $out/opt/DiscordCanary/resources/app
    substituteInPlace $out/opt/DiscordCanary/resources/app/index.js --replace 'REPLUGGED_SRC' '${replugged}'

    cp -a --remove-destination $(readlink "$out/opt/DiscordCanary/.DiscordCanary-wrapped") "$out/opt/DiscordCanary/.DiscordCanary-wrapped"
    cp -a --remove-destination $(readlink "$out/opt/DiscordCanary/DiscordCanary") "$out/opt/DiscordCanary/DiscordCanary"

    if grep '\0' $out/opt/DiscordCanary/DiscordCanary && wrapperCmd=$(${extractCmd} $out/opt/DiscordCanary/DiscordCanary) && [[ $wrapperCmd ]]; then
      # Binary wrapper
      parseMakeCWrapperCall() {
        shift # makeCWrapper
        oldExe=$1; shift
        oldWrapperArgs=("$@")
      }
      eval "parseMakeCWrapperCall ''${wrapperCmd//"${discord-canary.out}"/"$out"}"
      # Binary wrapper
      makeWrapper $oldExe $out/opt/DiscordCanary/DiscordCanary "''${oldWrapperArgs[@]}" --add-flags "${extraElectronArgs}"
    else
      # Normal wrapper
      substituteInPlace $out/opt/DiscordCanary/DiscordCanary \
      --replace '${discord-canary.out}' "$out" \
      --replace '"$@"' '${extraElectronArgs} "$@"'
    fi

    substituteInPlace $out/opt/DiscordCanary/DiscordCanary --replace '${discord-canary.out}' "$out"
  '';

  meta.mainProgram = if (discord-canary.meta ? mainProgram) then discord-canary.meta.mainProgram else null;
}
