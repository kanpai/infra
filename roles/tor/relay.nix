{ host, config, lib, pkgs, ... }: {
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

  persist.directories = lib.optional config.services.tor.enable {
    directory = "/var/lib/tor";
    user = "tor";
    group = "tor";
  };
}
