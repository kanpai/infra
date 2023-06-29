{ lib, config, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
    };
  };

  # persist host private keys (otherwise server fingerprint changes every reboot)
  environment.persistence.main.files = map (key: key.path) config.services.openssh.hostKeys;
}
