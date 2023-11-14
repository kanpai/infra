{ ... }:
let
  ap-interface = "wlan0";
in
{
  services.hostapd = {
    enable = true;
    radios.${ap-interface} = {
      band = "5g";
      channel = 136;
      countryCode = "DK";
      networks.${ap-interface} = {
        ssid = "headspace";
        authentication = {
          mode = "wpa2-sha256";
          wpaPassword = "rockpaperdepression";
        };
      };
    };
  };

  systemd.network.networks."20-ap" = {
    matchConfig.Name = ap-interface;
    networkConfig = {
      Address = "10.1.1.1/24";
      DHCPServer = true;
      IPMasquerade = "ipv4";
    };
    dhcpServerConfig = {
      PoolOffset = 100;
      PoolSize = 20;
    };
  };

  networking.firewall.allowedUDPPorts = [ 67 ];
}
