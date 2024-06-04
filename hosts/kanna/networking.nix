{ lib, host, ... }:
let
  mkLan = interface: {
    matchConfig.Name = interface;
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    dns = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"

      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
  networks = lib.listToAttrs (map
    (interface: {
      name = "10-lan-${interface}";
      value = mkLan interface;
    })
    [ "eno1" "eno2" ]);
in
{
  systemd.network = {
    enable = true;
    inherit networks;
  };

  networking = {
    hostName = host.name;
    hostId = "d44d7435";
    useNetworkd = true;
    dhcpcd.enable = true;
  };
}
