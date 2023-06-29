{ lib, config, ... }: {
  environment.persistence = lib.attrs.optional config.environment.persistence.main.enable {
    main.directories = [
      "/etc/ssh/host_keys"
    ];
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        bits = 4096;
        path = "/etc/ssh/host_keys/rsa_key";
        type = "rsa";
      }
      {
        path = "/etc/ssh/host_keys/ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PermitRootLogin = "prohibit-password";
    };
  };
}
