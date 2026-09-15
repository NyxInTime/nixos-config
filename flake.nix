{
  description = "Flake incorporating all systems";
  inputs = {
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    sops-nix.url = "github:Mic92/sops-nix";

    umbriel.url = "git+https://github.com/noctalia-dev/umbriel";
    xdg-desktop-portal-umbriel.url = "github:noctalia-dev/xdg-desktop-portal-umbriel";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland";
    reaper.url = "github:9Prestidigitator/reaper-flake";

  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      aagl,
      nixvim,
      noctalia-greeter,
      reaper,
      ...
    }@inputs:
    {
      # Configuration for laptop
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./laptop/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = { inherit inputs; };

              sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];

              users.nyx = import ./laptop/home.nix;

            };
          }
          {
            imports = [ aagl.nixosModules.default ];
            nix.settings = aagl.nixConfig; # Set up Cachix
            programs.anime-game-launcher = {
              enable = true; # Adds launcher and /etc/hosts rules
            };
            programs.anime-games-launcher.enable = true;
            programs.honkers-railway-launcher = {
              enable = true;
            };
            programs.honkers-launcher.enable = true;
            programs.wavey-launcher.enable = true;
            programs.sleepy-launcher.enable = true;
          }
          {
            imports = [ noctalia-greeter.nixosModules.default ];
            programs.noctalia-greeter = {
              enable = true;

              # Optional configuration
              greeter-args = "";
              # Full declarative greeter.toml (overwritten on each activation).
              # See examples/greeter.toml for every key (appearance.palette, output, …).
              settings = {
                keyboard = {
                  layout = "us";
                };
              };
            };

          }
          /*
            qylock.nixosModules.default
            ({ pkgs, ... }: {
              services.displayManager.sddm.enable = true;
              services.displayManager.sddm.wayland.enable = true;

              programs.qylock = {
                enable = true;
                theme = "terraria"; # any directory name under themes/
                # sddm.enable = true;             # installs theme + sets it active (default)
                # quickshell.enable = true;       # adds `qylock-lock` to PATH (default)

                # Optional per-theme tweaks (replaces the interactive prompts):
                themeOptions = {
                  terraria.backgroundMode = "time"; # time | random | static
                  Genshin.backgroundMode = "time";
                  clockwork.orbital = {
                    themeMode = "dark";
                    enableWindup = true;
                  };
                  osu.gameMode = "menu"; # menu | game
                };
              };
            })
          */
        ];
      };
      # first server configuration
      nixosConfigurations.nyxos-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./server/configuration.nix
          ./server/cloudflare_tunnel.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];

              users.nyx = import ./server/home.nix;
            };
          }
        ];
      };

    };
}
