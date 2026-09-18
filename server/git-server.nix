{
  config,
  pkgs,
  lib,
  ...
}:

let
  gitUser = "git";
  gitHome = "/home/git";
  readGroup = "git"; # group name that can read the git repos

  gitShellCommand = pkgs.writeShellScript "git-shell-commander" ''
    set -euo pipefail

    cmd="''${SSH_ORIGINAL_COMMAND:-}"
    [ -z "$cmd" ] && { echo "Interactive shell not allowed." >&2; exit 1; }

    subcmd="''${cmd%% *}"

    if [ "$subcmd" = "git-receive-pack" ]; then
      repo="''${cmd#* }"
      repo="''${repo//\'/}"
      repo="''${repo#/}"

      case "$repo" in
        *..*|.*)
          echo "Invalid repository path." >&2
          exit 1
          ;;
      esac

      full_path="${gitHome}/$repo"
      if [ ! -d "$full_path" ]; then
        # --shared=group makes the repo group-readable/writable and sets
        # core.sharedRepository=group so future pushes keep those perms
        ${pkgs.git}/bin/git init --quiet --bare --initial-branch=main --shared=group "$full_path" >&2
        echo "Created new repository: $repo" >&2
      fi
    fi

    exec ${pkgs.git}/bin/git shell -c "$cmd"
  '';

in
{
  users.users.${gitUser} = {
    isSystemUser = true;
    group = gitUser;
    extraGroups = [ readGroup ];
    home = gitHome;
    createHome = true;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgOwcuIVP2/67xR4ZsO4GYN0HQWBn7ZpZoVo8KM3yV6 nic@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKNBKEcGNfMYrY9xKglUOQ4f6oSw+JNEDx1ABnQ/yNd7 u0a390@localhost"
    ];
  };

  users.groups.${gitUser} = { };
  #users.groups.${readGroup} = { };

  # Make gitHome owned by group `readGroup`, with the setgid bit so any
  # repo git creates underneath inherits that group automatically.
  systemd.tmpfiles.rules = [
    "z ${gitHome} 2750 ${gitUser} ${readGroup} -"
    "d ${gitHome}/git-shell-commands 0750 ${gitUser} ${gitUser} -"
    # Symlink our wrapper into git-shell's custom-commands directory
    "L+ ${gitHome}/git-shell-commands/git-shell-commander - - - - ${gitShellCommand}"
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;

    extraConfig = ''
      Match User ${gitUser}
        ForceCommand git-shell-commander
      Match all
    '';
  };

  environment.systemPackages = [ pkgs.git ];
}
