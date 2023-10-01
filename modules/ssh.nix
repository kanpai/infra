{ lib, config, settings, ... }:
with lib;
{
  services.openssh = mkDefault {
    enable = true;
    allowSFTP = false;
    ports = [ 12248 ];
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "no";
      AllowStreamLocalForwarding = "no";
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # persist host private keys (otherwise server fingerprint changes every reboot)
  persist.files =
    if config.services.openssh.enable
    then map (key: key.path) config.services.openssh.hostKeys
    else [ ];

  # add admin ssh keys
  users.users.root.openssh.authorizedKeys.keys = builtins.foldl' (acc: admin: acc ++ admin.keys.ssh) [] settings.admins;
}
