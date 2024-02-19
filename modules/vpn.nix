{ config, ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.vpn-preauth.path;
    extraUpFlags = [ "--login-server=https://headscale.kanp.ai" ];
  };

  age.secrets.vpn-preauth.file = ../secrets/vpn-preauth.age;
}
