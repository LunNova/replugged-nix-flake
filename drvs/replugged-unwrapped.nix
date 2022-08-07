{ lib
, mkYarnPackage
, replugged-src
}:
(mkYarnPackage {
  name = "replugged-unwrapped";
  src = replugged-src;
  yarnLock = ../misc/yarn.lock;

  patches = [
    ../misc/replugged.patch
    ../misc/fix-back-handling.patch
  ];

  # Disable update checking
  postPatch = ''
    substituteInPlace src/Powercord/plugins/pc-updater/index.js --replace "'paused', false" "'paused', true"
    substituteInPlace src/Powercord/index.js --replace "this.gitInfos = await this.pluginManager.get('pc-updater').getGitInfos();" " "
  '';

  installPhase = ''
    runHook preInstall

    mv deps/replugged $out
    rm $out/node_modules

    runHook postInstall
  '';

  meta = {
    homepage = "https://replugged.dev";
    license = lib.licenses.mit;
    description = "A lightweight discord mod focused on simplicity and performance";
  };
}).overrideAttrs (_: {
  doDist = false;
})
