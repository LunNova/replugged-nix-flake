# replugged-nix-flake
A flake with derivations for [replugged](https://replugged.dev) and discord stable with replugged set up.

Based on [LavaDesu's powercord-overlay](https://github.com/LavaDesu/powercord-overlay).

## Updates

Every day github actions updates this flake, and only pushes if the build still works.

#### 2022-10-1

* Replugged is currently broken. See [https://github.com/LunNova/replugged-nix-flake/issues/6](https://github.com/LunNova/replugged-nix-flake/issues/6).
* Added `withOpenAsar` option to config which uses [openasar.dev](https://openasar.dev/). Allows for some theming, no declarative config.

#### 2022-09-26

* Changed default discord package to discord stable, as replugged is not currently working on canary and replugged does not recommend canary. Canary used to be required by powercord.

## Installation
### With flakes
```nix
# flake.nix
{
  inputs.replugged-nix-flake.url = "github:LunNova/replugged-nix-flake";
}
# TODO: explain how to get this available in other files using specialArgs? Or find somewhere to link
```

### Without flakes
```nix
let
  replugged-nix-flake = import (builtins.fetchTarball "https://github.com/LunNova/replugged-nix-flake/archive/main.tar.gz");
in
...
```

## Usage
### Install discord-plugged
```nix
{
  # replugged-nix-flake needs to be in scope

  # or home.packages with home-manager
  environment.systemPackages = [
    (replugged-nix-flake.lib.makeDiscordPlugged {
      inherit pkgs;
    })
  ];
}
```

### Using openasar

```nix
(replugged-nix-flake.lib.makeDiscordPlugged {
  inherit pkgs;
  withOpenAsar = true;
});
```

### Plugins/Themes
For plugins and/or themes, override `discord-plugged`

Example:
```nix
# where you put your packages
(replugged-nix-flake.lib.makeDiscordPlugged {
  inherit pkgs;
  plugins = {
    discord-tweaks = (builtins.fetchTarball "https://github.com/NurMarvin/discord-tweaks/archive/master.tar.gz");
  };
  themes = {
    tokyo-night = (builtins.fetchTarball "https://github.com/Dyzean/Tokyo-Night/archive/master.tar.gz");
  };
})
```

If you're using flakes, you can instead use inputs to fetch them
```nix
# flake.nix
{
  inputs = {
    discord-tweaks = { url = "github:NurMarvin/discord-tweaks"; flake = false; };
    discord-tokyonight = { url = "github:Dyzean/Tokyo-Night"; flake = false; };
  };
}
```
```nix
# where you put your packages
(inputs.replugged-nix-flake.lib.makeDiscordPlugged {
  inherit pkgs;
  plugins = {
    inherit (inputs) discord-tweaks;
  };
  themes = {
    inherit (inputs) discord-tokyonight;
  };
})
```

## Use a different discord version
```
(replugged-nix-flake.lib.makeDiscordPlugged {
  inherit pkgs;
  plugins = {
    ...
  };
  themes = {
    ...
  };
  discord = pkgs.discord-canary;
  # Discord binaries/folders have a different suffix in different packages
  discordPathSuffix = "Canary";
})
```

## Additional notes
- The updater should be disabled, it doesn't work for obvious reasons :)
  - I tried to disable it by patching but that might not work
- Settings are stored imperatively in `$XDG_CONFIG_HOME/powercord`
  (and cache in `$XDG_CACHE_HOME/powercord`)
  - This unforunately is not perfect. If you notice some plugin's settings just disappear
    after a restart (as it tried to write to the store), please open an issue here about it

## Some disclaimers
Replugged *is* against Discord's Terms of Service. However, at the time of writing, Discord isn't
currently hunting down modded client users and punishing them or anything.

While you *should* be safe, **you are at your own risk** when using this overlay, and I am not
responsible for any damages that may happen as a result of using Powercord.
