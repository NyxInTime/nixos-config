{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  home.username = lib.mkForce "nyx";
  home.homeDirectory = lib.mkForce "/home/nyx";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    nodejs
    pkgs.devenv
    inputs.hytale-launcher.packages.${pkgs.system}.default
  ];

  imports = [
    ./../nixvim.nix
    inputs.umbriel.homeModules.default
    inputs.noctalia.homeModules.default
    inputs.reaper.homeModules.reaper
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "NyxInTime";
        email = "nyx@nicintime.ca";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
    signing = {
      format = "ssh";
      signByDefault = true;
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /home/nyx/.config/nixos/";
      update = "sudo nix flake update --flake /home/nyx/.config/nixos/";
      ssh-nyx = "ssh nyx@ssh.nicintime.ca";
      ssh-testing = "ssh testing@ssh2.nicintime.ca";
      hypr = "start-hyprland";
      dawson-vpn = "sudo openfortivpn -c ~/.config/nixos/vpn-config.txt --saml-login";
      run-html = "xdg-open";
      html-server = "python3 -m http.server";
      nuclear-player = "playerctl --player=$(playerctl --list-all | grep org.webkit.app)";
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaMauve;
    name = "catppuccin-mocha-mauve-cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve-cursors";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {

      "Host *.nicintime.ca" = {
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
      };

    };
  };

  programs.umbriel = {
    enable = true;
    settings = {
      general.autostart = [ "noctalia" ];
      layout.gap = 5;
      input.keyboard.layout = "us";
      keybinds = {
        "Mod+Return" = "spawn:kitty";
        "Mod+Q" = "window-close";
        "Mod" = "spawn:noctalia msg panel-toggle launcher";
        "Mod+WheelUp" = "window-focus-left";
        "Mod+WheelDown" = "window-focus-right";
        "Mod+Shift+WheelUp" = "window-focus-or-workspace-up";
        "Mod+Shift+WheelDown" = "window-focus-or-workspace-down";
        "Mod+F" = "window-cycle-width";
        "Mod+MouseForward" = "spawn:firefox";
        "Mod+MouseBack" = "spawn:kitty";
        "Mod+Print" = "spawn:noctalia msg screenshot-region";
      };
      layout = {
        mode = "scrolling";
        width_presets = [
          0.333
          0.5
          0.667
          0.9
          1
        ];
      };

    };
  };

  programs.noctalia = {
    enable = true;

    settings = {
      # This may also be a string or path to a .toml file.
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      wallpaper = {
        enabled = true;
        default.path = "/home/nix/.config/wallpaper/wallpaper3/jpg";
      };
    };
  };

  programs.vesktop.enable = true;

  programs.reaper = {
    enable = true;
    extensions = {
      reapack.enable = true;
      sws = {
        enable = true;
        colors = [
          "#F5E0E6"
          "#F2CDCD"
          "#F5C2E7"
          "#CBA6F7"
        ];
      };
    };

    preferences = {
      general.startupSettings.showSplashScreenOnStartup = false;
      project.trackSendDefaults.trackVolumeFaderGain = -10.0;
      plugIns.reascript.python.enable = true;
    };
  };

  #xdg.userDirs = {
  #enable = true;
  #createDirectories = true;
  #};

}
