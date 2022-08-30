{ lib
, replugged-unwrapped
, stdenvNoCC
, withPlugins ? { }
, withThemes ? { }
}:
let
  unwrapped = replugged-unwrapped;
in
stdenvNoCC.mkDerivation {
  name = "replugged";
  src = unwrapped.out;

  installPhase =
    let
      fromDrvs = lib.mapAttrsToList
        (k: drv: {
          inherit (drv) outPath;
          name = lib.strings.sanitizeDerivationName k;
        });

      map = n: lib.concatMapStringsSep "\n"
        (e: ''
          chmod 755 $out/${n}
          cp -a ${e.outPath} $out/${n}/${e.name}
          chmod -R u+w $out/${n}/${e.name}
        '');

      mappedPlugins = map "plugins" (fromDrvs withPlugins);
      mappedThemes = map "themes" (fromDrvs withThemes);
    in
    ''
      cp -a $src $out
      chmod 755 $out
      ln -s ${unwrapped.deps}/node_modules $out/node_modules
      ${mappedPlugins}
      ${mappedThemes}
    '';

  passthru.unwrapped = unwrapped;
  meta = unwrapped.meta // {
    priority = (unwrapped.meta.priority or 0) - 1;
  };
}
