{ klib, lib, config, ... }:
{
  services.openssh = lib.mkDefault {
    enable = true;
    allowSFTP = false;
    listenAddresses = lib.flatten (map
      (port: [
        { addr = "0.0.0.0"; inherit port; }
        { addr = "[::]"; inherit port; }
      ])
      [ 22 12248 ]);
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "no";
      AllowStreamLocalForwarding = "no";
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 12248 ];
    interfaces.tailscale0.allowedTCPPorts = [ 22 ];
  };

  # persist host private keys (otherwise server fingerprint changes every reboot)
  persist.files =
    if config.services.openssh.enable
    then map (key: key.path) config.services.openssh.hostKeys
    else [ ];

  # add admin ssh keys
  users.users.root.openssh.authorizedKeys.keys = klib.getKeys "admins" [ "ssh" ];
}
