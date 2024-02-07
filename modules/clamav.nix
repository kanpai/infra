{ ... }: {
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
    scanner = {
      enable = true;
      scanDirectories = [
        "/persist"
        "/tmp"
        "/var/tmp"
      ];
    };
  };
}
