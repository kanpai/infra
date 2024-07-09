{ ... }: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
    scanner = {
      enable = true;
      scanDirectories = [
        "/boot"
        "/nix"
        "/persist"
        "/tmp"
        "/var/tmp"
      ];
    };
  };
}
