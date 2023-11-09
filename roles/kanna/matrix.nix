{ lib, config, host, inputs, pkgs, ... }:
let
  serverName = "kanp.ai";
  matrixHostname = "matrix.${serverName}";

  wellknownServer = {
    "m.server" = matrixHostname;
  };
  wellknownClient = {
    "m.homeserver".base_url = "https://${matrixHostname}:${toString cfg.settings.global.port}";
    "org.matrix.msc3575.proxy".url = "https://${matrixHostname}";
  };

  cfg = config.services.matrix-conduit;
in
{
  services = {
    matrix-conduit = {
      enable = true;
      package = inputs.conduit.packages.${host.system}.default;
      settings = {
        global = {
          server_name = serverName;
          allow_registration = true;
          enable_lightning_bolt = false;
          max_request_size = 104857600; # 100MiB
          database_backend = "rocksdb";
        };
      };
    };
  };

  users = {
    groups.conduit = { };
    users.conduit = {
      isSystemUser = true;
      group = "conduit";
    };
  };

  persist.directories = lib.optional cfg.enable {
    directory = "/var/lib/private/matrix-conduit";
    user = "conduit";
    group = "conduit";
    mode = "0770";
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 8448 ];
    allowedUDPPorts = [ 80 443 8448 ];
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    upstreams = {
      "backend_conduit".servers = {
        "[::1]:${toString cfg.settings.global.port}" = { };
      };
    };

    virtualHosts = {
      ${matrixHostname} = {
        enableACME = true;
        forceSSL = true;

        listen = [
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::]"; port = 443; ssl = true; }
          { addr = "0.0.0.0"; port = 8448; ssl = true; }
          { addr = "[::]"; port = 8448; ssl = true; }
        ];

        extraConfig = ''
          merge_slashes off;
        '';

        locations = {
          "/".return = "307 'https://${serverName}'";
          "/_matrix/" = {
            proxyPass = "http://[::1]:${toString cfg.settings.global.port}$request_uri";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_buffering off;
              client_max_body_size ${toString cfg.settings.global.max_request_size};
            '';
          };
        };
      };

      ${serverName} = {
        enableACME = true;
        forceSSL = true;

        locations = {
          "/" = lib.mkDefault { return = "444"; }; # no response

          "=/.well-known/matrix/server" = {
            extraConfig = ''default_type application/json;'';
            return = "200 '${builtins.toJSON wellknownServer}'";
          };
          "=/.well-known/matrix/client" = {
            extraConfig = ''
              default_type application/json;
              add_header Access-Control-Allow-Origin "*";
            '';
            return = "200 '${builtins.toJSON wellknownClient}'";
          };
        };
      };
    };
  };

  # conduit db debugging
  environment.systemPackages = [ pkgs.rocksdb.tools ];
}
