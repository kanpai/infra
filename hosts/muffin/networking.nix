{ ... }:
let
  networks = {
    "10-lan" = {
      matchConfig.Name = "enp6s0";
      networkConfig.DHCP = "no";
      address = [
        "192.168.1.100/24"
        #"fe80::1337:dead:babe:b100/64"
      ];
      dns = [
        "9.9.9.9"
        "149.112.112.112"
        "[2620:fe::fe]"
        "[2620:fe::9]"
      ];
      routes = [
        { routeConfig.Gateway = "192.168.1.254"; }
        { routeConfig.Gateway = "fe80::1"; }
      ];
    };
  };
  links = { };
  netdevs = { };
in
{
  systemd.network = {
    enable = true;
    inherit networks links netdevs;
  };

  /*
    networking = {
    hostId = "ea2a80b5";
    interfaces.enp6s0 = {
      wakeOnLan.enable = true;
    };
    };
  */
}
