{ lib, config, ... }:
with lib;
{
  services.openssh = mkDefault {
    enable = true;
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
  persist.files =
    if config.services.openssh.enable
    then map (key: key.path) config.services.openssh.hostKeys
    else [ ];
}
