{ host, config, lib, pkgs, ... }: {
  services.tor = {
    enable = lib.mkDefault true;
    openFirewall = true;
    settings = {
      ControlPort = [ { port = 9051; } ];
      ORPort = [ 9001 ];
      Nickname = lib.mkDefault "KANPAI${host.name}";
      ContactInfo = lib.mkDefault "mib(at)mib(dot)dev";
      CookieAuthentication = true;
    };
  };

  environment.systemPackages = [ pkgs.nyx ];

  persist.directories = lib.optional config.services.tor.enable {
    directory = "/var/lib/tor";
    user = "tor";
    group = "tor";
  };
}
