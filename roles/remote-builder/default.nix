{ pkgs, config, settings, ... }:
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

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.binary-cache-private-key.path;
    };
    nginx = {
      enable = true;
      virtualHosts."${config.networking.hostName}.kanpai".locations."/".proxyPass =
        "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
    };
  };

  age.secrets.binary-cache-private-key.file =
    "${../../secrets}/binary_cache-${config.networking.hostName}-private_key.age";
}
