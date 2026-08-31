# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./git-server.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nyxos-server"; # Define your hostname.

  # Website hosting

  users.users.nginx.extraGroups = [
    "acme"
    "git"
  ];
  services.fcgiwrap.instances."git-http-backend" = {
    socket = {
      type = "unix";
      address = "/run/fcgiwrap.sock";
      user = "git";
      group = "git";
      mode = "0660";
    };
    process = {
      user = "git";
      group = "git";
    };
  };
  services.nginx = {

    enable = true;
    virtualHosts."nicintime.ca" = {
      onlySSL = true;
      enableACME = true;
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
          ssl = true;
        }
      ];

      extraConfig = ''
                port_in_redirect off;
        	expires -1;
                add_header Cache-Control "no-cache, must-revalidate, max-age=0";
      '';

      locations."/" = {
        root = "/var/www/website";
      };
      locations."= /custom.css" = {
        alias = "/var/www/website/custom-cgit.css";
        extraConfig = ''
          # Prevents browser caching from hiding your edits during testing
          add_header Cache-Control "no-cache, must-revalidate, max-age=0";
        '';
      };
      locations."= /logo.png" = {
        alias = "/var/www/website/logo.png";

      };
    };
    virtualHosts."clone.nicintime.ca" = {
      onlySSL = true;
      enableACME = true;
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
          ssl = true;
        }
      ];

      extraConfig = ''
        port_in_redirect off;
      '';

      locations."~ (/.*)" = {

        # This is where the repositories live on the server
        root = "/home/git";

        # Setup FastCGI for Git HTTP Backend
        extraConfig = ''
          fastcgi_pass        unix:/run/fcgiwrap.sock;
          include             ${pkgs.nginx}/conf/fastcgi_params;
          # All parameters below will be forwarded to fcgiwrap which then starts
          # the git http proces with the the params as environment variables except
          # for SCRIPT_FILENAME. See "man git-http-server" for more information on them.
          fastcgi_param       SCRIPT_FILENAME     ${pkgs.git}/bin/git-http-backend;
          fastcgi_param       GIT_PROJECT_ROOT /home/git;
          # CAREFULL! only include this option if you want all the repos in $root to
          # to be read.
          fastcgi_param       GIT_HTTP_EXPORT_ALL "";
          # use the path from the regex in the location
          fastcgi_param       PATH_INFO           $1;
        '';
      };

    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nyx@nicintime.ca";
  };

  services.cgit.whatever = {
    enable = true;
    scanPath = "/home/git";
    gitHttpBackend.enable = false;
    user = "git";
    group = lib.mkForce "git";

    nginx = {
      location = "/cgit";
      virtualHost = "nicintime.ca";
    };
    settings = {
      css = "/custom-cgit.css";
      logo = "/logo.png"; # to actually have a custom logo, add one to /var/www/website
    };

    extraConfig = ''
      head-include=/var/www/website/head.html
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080
    9418
    8000
  ];

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Montreal";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  programs.nix-ld.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };
  users.users.nyx = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "git"
      "nginx"
      #"gitreporeaders"
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  environment.systemPackages = with pkgs; [
    vim
    cloudflared
    tmux
    postfix
    rustup
    gcc
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
