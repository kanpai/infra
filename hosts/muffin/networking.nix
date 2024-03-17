{ host, ... }:
let
  networks = {
    "10-lan" = {
      matchConfig.Name = "enp6s0";
      networkConfig = {
        DHCP = "yes";
      };
      address = [
        "192.168.1.100/24"
      ];
      dns = [
        "9.9.9.9"
        "149.112.112.112"
        "1.1.1.1"
        "1.0.0.1"
      ];
      routes = [
        { routeConfig.Gateway = "192.168.1.254"; }
      ];
    };
  };
  links = { };
  netdevs = { };
  # missing wakeOnLan
in
{
  systemd.network = {
    enable = true;
    inherit networks links netdevs;
  };

  networking = {
    hostName = host.name;
    useNetworkd = true;
    dhcpcd.enable = false;
  };
}
