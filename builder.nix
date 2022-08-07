{ pkgs, replugged-src, themes ? { }, plugins ? { }, extraElectronArgs ? "" }:
let
  self =
    {
      replugged-unwrapped = pkgs.callPackage ./drvs/replugged-unwrapped.nix {
        inherit replugged-src;
      };

      replugged = pkgs.callPackage ./drvs/replugged.nix {
        inherit (self) replugged-unwrapped;
        withPlugins = plugins;
        withThemes = themes;
      };

      discord-plugged = pkgs.callPackage ./drvs/discord-plugged.nix {
        inherit extraElectronArgs;
        inherit (self) replugged;
      };
    };
in
self
