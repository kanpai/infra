{ config, ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.vpn-preauth.path;
    extraUpFlags = [
      "--login-server=https://headscale.kanp.ai"
      "--accept-dns=false"
    ];
  };

  # should upstream a change that makes tailscale run as proper user with right permissions.
  # it really shouldn't run as root...
  persist.directories = [{
    directory = "/var/lib/tailscale";
    mode = "700";
    user = "root";
    group = "root";
  }];

  age.secrets.vpn-preauth.file = ../secrets/vpn-preauth.age;
}
