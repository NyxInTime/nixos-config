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
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nyx.In.Time";
        email = "nyx@nicintime.ca";
      };
      init.defaultBranch = "main";
    };
    signing = {
      format = "ssh";
      signByDefault = true;
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
    extraConfig = {
      pull.rebase = false;
      push.autoSetupRemote = true;
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
      };
      layout = {
        mode = "scrolling";
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

  #xdg.userDirs = {
  #enable = true;
  #createDirectories = true;
  #};

}
