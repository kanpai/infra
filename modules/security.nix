{ lib, ... }: {
  # lock down nix to root
  nix.allowedUsers = [ "root" ];


  # disable sudo
  security.sudo.enable = false;

  # no default packages
  environment.defaultPackages = lib.mkForce [ ];

  # enable auditing
  security = {
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
