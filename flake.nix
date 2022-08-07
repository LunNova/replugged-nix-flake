{
  description = "A Nix flake with packages for Replugged, the successor to Powercord. Based on github.com/LavaDesu's overlay for powercord.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    replugged.url = "github:replugged-org/replugged";
    replugged.flake = false;
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      replugged-src = inputs.replugged;
      builder = import ./builder.nix;
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      lib =
        let
          self = {
            makeDiscordPluggedPackageSet = builder-args: builder { inherit replugged-src; } // builder-args;
            makeDiscordPlugged = args: (self.makeDiscordPluggedPackageSet args).discord-plugged;
          };
        in
        self;
      overlay = pkgs: prev: (builder {
        inherit pkgs replugged-src;
      });
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        builder { inherit pkgs replugged-src; });
    };
}
