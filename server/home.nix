{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "nyx";
  home.homeDirectory = "/home/nyx";
  home.stateVersion = "26.05";

  imports = [
    ./../nixvim.nix
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "NyxInTime";
        email = "nyx@nicintime.ca";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
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
      rebuild = "tmux new-session -s rebuild 'sudo nixos-rebuild switch --flake /home/nyx/.config/nixos/; bash'";
      reattach = "tmux attach -t rebuild";
      update = "sudo nix flake update --flake /home/nyx/.config/nixos/";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {

      "Host *.nicintime.ca" = {
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        AddressFamily = "inet";
      };
      "Host ssh-git.nicintime.ca" = {
        ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        AddressFamily = "inet";
      };

    };
  };
}
