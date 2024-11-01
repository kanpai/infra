{ lib, pkgs, config, ... }:
let
  enable = true;
  domain = "headscale.kanp.ai";
  port = 443;

  cfg = config.services.headscale;
  service = config.systemd.services.headscale.serviceConfig;

  headscale-ui = pkgs.buildNpmPackage rec {
    pname = "headscale-ui";
    version = "2024.10.10";

    src = pkgs.fetchFromGitHub {
      owner = "gurucomputing";
      repo = "headscale-ui";
      rev = version;
      hash = "sha256-r7LWzna6ZI5hI5ojyfWssqQc+IA3vInSwDlmXGBmhZQ=";
    };

    npmDepsHash = "sha256-/xMZc0q+/iAf7mhTOX9abNC+6AdUNzkQRQ5qRgRqY+o=";
    makeCacheWritable = true;

    installPhase = ''
      runHook preInstall

      npm install
      cp -r build $out

      runHook postInstall
    '';
  };
in
lib.mkIf enable {
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 50000;
      settings =
        let
          certDir = config.security.acme.certs.${domain}.directory;
        in
        {
          server_url = "https://${domain}:${toString port}";
          tls_key_path = "${certDir}/key.pem";
          tls_cert_path = "${certDir}/cert.pem";
          dns.base_domain = "kanpai";
          database = {
            type = "postgres";
            postgres = {
              host = "/run/postgresql";
              port = null;
              name = "headscale";
              user = "headscale";
            };
          };
        };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "${domain}" = {
          useACMEHost = domain;
          forceSSL = true;
          locations = {
            "/" = {
              proxyWebsockets = true;
              proxyPass = "https://${cfg.address}:${toString cfg.port}";
            };
            "~^/web/([a-zA-Z0-9/~._-]*)".alias = "${headscale-ui}/$1";
          };
        };
        "www.${domain}" = {
          useACMEHost = domain;
          forceSSL = true;
          locations."/".return = "308 https://${domain}/$request_uri";
        };
      };
    };
    postgresql = {
      ensureDatabases = [ "headscale" ];
      ensureUsers = [{ name = "headscale"; ensureDBOwnership = true; }];
    };
  };

  # allow nginx to use acme headscale certificate for web ui
  users.users.nginx.extraGroups = [ "headscale" ];

  security.acme.certs.${domain} = {
    inherit (cfg) group;
    extraDomainNames = [ "www.${domain}" ];
  };

  persist.directories = [{
    directory = "/var/lib/headscale";
    mode = service.StateDirectoryMode;
    inherit (cfg) user group;
  }];
}
