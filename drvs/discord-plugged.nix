{ lib
, symlinkJoin
  # This should usually be discord-${discordPathSuffix} but other versions can work
, discord
, replugged
, makeBinaryWrapper
, writeShellScript
, extraElectronArgs ? ""
, discordPathSuffix ? ""
, withOpenAsar ? false
}:
let
  extractCmd = makeBinaryWrapper.extractCmd or (writeShellScript "extract-binary-wrapper-cmd" ''
    strings -dw "$1" | sed -n '/^makeCWrapper/,/^$/ p'
  '');
  openAsar = builtins.fetchurl {
    name = "app.asar";
    url = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/436587361/528ec0c9-da3d-42d7-8fe6-4078e47e128c?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20221001%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20221001T192103Z&X-Amz-Expires=300&X-Amz-Signature=8c5363c1c99e9f32b99a205783cea3cd68938b2bc46bf98d3dab86173588c1bd&X-Amz-SignedHeaders=host&actor_id=782440&key_id=0&repo_id=436587361&response-content-disposition=attachment%3B%20filename%3Dapp.asar&response-content-type=application%2Foctet-stream";
    sha256 = "sha256:173wc5q3wqbx5p2qf5yvhgbwpds1v9v266285hzjv39r7zkb531k";
  };
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
  '' + (lib.optionalString withOpenAsar ''
    rm $out/opt/Discord${discordPathSuffix}/resources/app.asar
    cp ${openAsar} $out/opt/Discord${discordPathSuffix}/resources/app.asar
  '');

  meta.mainProgram = if (discord.meta ? mainProgram) then discord.meta.mainProgram else null;
}
