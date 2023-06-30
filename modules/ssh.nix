{ lib, config, ... }:
with lib;
{
  services.openssh = mkDefault {
    passwordAuthentication = false;
    allowSFTP = false;
    challengeResponseAuthentication = false;
    settings = {
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "no";
      AllowStreamLocalForwarding = "no";
      X11Forwarding = "no";
      PermitRootLogin = "prohibit-password";
    };
  };

  # persist host private keys (otherwise server fingerprint changes every reboot)
  persist.files = map (key: key.path) config.services.openssh.hostKeys;
}
