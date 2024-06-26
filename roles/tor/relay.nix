{ host, config, lib, pkgs-23_11, ... }: {
  services = {
    tor = {
      enable = true;
      openFirewall = true;
      settings = {
        ControlPort = [{ port = 9051; }];
        ORPort = [ 9001 ];
        Nickname = lib.mkDefault "KANPAI${host.name}";
        ContactInfo = lib.mkDefault "mib(at)mib(dot)dev";
        CookieAuthentication = true;
      };
    };

    prometheus.exporters.tor = {
      enable = true;
      openFirewall = true;
      user = "tor";
      torControlPort = builtins.head (map (m: m.port) config.services.tor.settings.ControlPort);
    };
  };

  environment.systemPackages = [ pkgs-23_11.nyx ];
}
