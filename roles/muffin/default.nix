{ pkgs, ... }:
{
  imports = [ ];

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILof6lu+/Kd8bVgVgFKVhYIrjwHS+IFenacH/tdrkN8/ mib@hamilton"
      ];
    };
  };
}
