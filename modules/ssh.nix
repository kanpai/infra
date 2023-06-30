{ lib, config, ... }:
with lib;
{
  services.openssh = mkDefault {
    settings = {
      PermitRootLogin = "prohibit-password";
    };
  };

  # persist host private keys (otherwise server fingerprint changes every reboot)
  persist.files = map (key: key.path) config.services.openssh.hostKeys;
}
