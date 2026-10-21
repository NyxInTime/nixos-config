{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {

    # 2. Assign a static IP address to your sharing Ethernet interface
    interfaces.eno1.ipv4.addresses = [
      {
        address = "192.168.100.1";
        prefixLength = 24;
      }
    ];

    # 3. Enable NAT (Network Address Translation)
    nat = {
      enable = true;
      internalInterfaces = [ "eno1" ]; # The interface sharing the internet
      externalInterface = "wlan0"; # The interface providing the internet
    };
  };
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "eno1" ];
      };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      subnet4 = [
        {
          id = 1;
          subnet = "192.168.100.0/24";
          pools = [ { pool = "192.168.100.10 - 192.168.100.50"; } ];
          option-data = [
            {
              name = "routers";
              data = "192.168.100.1";
            }
            {
              name = "domain-name-servers";
              data = "1.1.1.1, 8.8.8.8";
            }
          ];
        }
      ];
    };
  };
}
