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
      openssh.authorizedKeys.keys = builtins.foldl' (acc: admin: acc ++ admin.keys.build) [ ] settings.admins;
    };
    groups.${user} = { };
  };
  nix.settings.trusted-users = [ user ];
}
