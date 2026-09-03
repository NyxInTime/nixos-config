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
        name = "Nic.In.Time";
        email = "nicintime9@gmail.com";
      };
      init.defaultBranch = "main";
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
    };
  };
}
