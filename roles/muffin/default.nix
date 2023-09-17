{ pkgs, settings, ... }:
{
  imports = [
    ./monitoring.nix
  ];

  system.autoUpgrade.enable = false;
  services.openssh.enable = true;

  users = {
    mutableUsers = false;
    users = {
      root.openssh.authorizedKeys.keys = map (admin: admin.ssh.key) settings.admins;
    };
  };
}
