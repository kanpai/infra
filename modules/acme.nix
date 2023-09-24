{ lib, config, ... }:
let
  cfg = config.security.acme;
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "mib@mib.dev";
      webroot = "/var/lib/acme/acme-challenge";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      # defaults to production; testing should be done with staging
      # https://acme-staging-v02.api.letsencrypt.org/directory
    };
  };

  users.users = lib.mkIf cfg.acceptTerms (
    let
      addGroup = { user, enabled }: lib.attrsets.optionalAttrs enabled { ${user}.extraGroups = [ "acme" ]; };
    in
    builtins.foldl' (l: r: l // (addGroup r)) { } (with config.services; [
      { user = nginx.user; enabled = nginx.enable; }
    ])
  );

  persist.directories = lib.optionals cfg.acceptTerms
    (map
      (cert: {
        inherit (cert) directory;
        user = "acme";
        group = "acme";
      })
      (lib.attrsets.attrValues cfg.certs));
}
