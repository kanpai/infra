{ pkgs, settings, ... }:
let
  user = "remote-builder";
in
{
  users = {
    users.${user} = {
      isSystemUser = true;
      group = user;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = builtins.foldl' (acc: admin: acc ++ admin.keys.ssh) [ ] settings.admins;
    };
    groups.${user} = { };
  };
  nix.settings.trusted-users = [ user ];
}
