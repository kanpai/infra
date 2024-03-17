{ host, ... }:
let
  networks = {
    "10-lan" = {
      matchConfig.Name = "end0";
      networkConfig.DHCP = "yes";
      address = [
        "192.168.0.128/24"
        "fe80::dead:babe:cafe/64"
      ];
      dns = [
        "9.9.9.9"
        "149.112.112.112"
        "1.1.1.1"
        "1.0.0.1"
      ];
      routes = [
        { routeConfig.Gateway = "192.168.0.1"; }
      ];
    };
  };
in
{
  systemd.network = {
    enable = true;
    inherit networks;
  };

  networking = {
    hostName = host.name;
    hostId = "57c4d638";
    useNetworkd = true;
    dhcpcd.enable = true;
  };
}
