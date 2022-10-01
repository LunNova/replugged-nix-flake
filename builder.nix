# Either builds a self contained package set, or can be an overlay if you set the overlayFinal arg
# in which case it uses the overlay's fixed point and not its own built in one
# discord arg is the discord package you want to add replugged to, defaults to pkgs.discord
{ pkgs
, replugged-src
, discord ? null
, themes ? { }
, plugins ? { }
, extraElectronArgs ? ""
, discordPathSuffix ? ""
, overlayFinal ? null
, withOpenAsar ? false
}:
let
  overlayFinalOrSelf = if (overlayFinal == null) then self else overlayFinal;
  self =
    {
      replugged-unwrapped = pkgs.callPackage ./drvs/replugged-unwrapped.nix {
        inherit replugged-src;
      };

      replugged = pkgs.callPackage ./drvs/replugged.nix {
        inherit (overlayFinalOrSelf) replugged-unwrapped;
        withPlugins = plugins;
        withThemes = themes;
      };

      discord-plugged = pkgs.callPackage ./drvs/discord-plugged.nix {
        inherit extraElectronArgs discordPathSuffix withOpenAsar;
        inherit (overlayFinalOrSelf) replugged;
        discord = if discord != null then discord else pkgs.discord;
      };
    };
in
self
