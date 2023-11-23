{ lib, config, host, pkgs, ... }:
let
  serverName = "kanp.ai";
  matrixHostname = "matrix.${serverName}";

  wellknownServer = {
    "m.server" = matrixHostname;
  };
  wellknownClient = {
    "m.homeserver".base_url = "https://${matrixHostname}";
    "org.matrix.msc3575.proxy".url = "https://${matrixHostname}";
  };

  makeSet = maker: opts:
    lib.lists.foldl
      lib.attrsets.recursiveUpdate
      { }
      (map maker opts);

  cfg = config.services.matrix-conduit;
in
{
  services = {
    matrix-conduit = {
      enable = true;
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

    # bridges
    postgresql = makeSet
      (name: {
        ensureDatabases = [ name ];
        ensureUsers = [{ inherit name; ensureDBOwnership = true; }];
      })
      [
        "mx-puppet-discord"
        "mautrix-facebook"
      ];

    mx-puppet-discord = {
      enable = cfg.enable;
      serviceDependencies = [ "postgresql.service" "matrix-conduit.service" ];
      settings = {
        bridge = {
          port = 8434;
          domain = serverName;
          homeserverUrl = "https://${matrixHostname}";
          displayname = "Discord Bridge";
          enableGroupSync = false;
        };
        database.connString = "postgres://mx-puppet-discord@/mx-puppet-discord?host=/run/postgresql";
        presence.enabled = false;
        provisioning.whitelist = [ "@.*:${serverName}" ];
        selfService.whitelist = [ "@.*:${serverName}" ];
        relay.whitelist = [ "@.*:${serverName}" ];
        namePatterns = {
          user = ":name";
          userOverride = ":displayname (:name in :guild/:channel)";
          room = ":name (:guild)";
        };
      };
    };

    mautrix-facebook = {
      enable = cfg.enable;
      configurePostgresql = false;
      environmentFile = config.age.secrets.matrix-bridge-facebook.path;
      settings = {
        appservice = rec {
          address = "http://${hostname}:${toString port}";
          hostname = "localhost";
          port = 29319;

          database = "postgresql://mautrix-facebook@/mautrix-facebook?host=/run/mautrix-facebook";
          bot_username = "facebook";
        };

        homeserver = {
          address = "https://${matrixHostname}";
          domain = serverName;
        };

        bridge = {
          encryption = {
            allow = true;
            default = true;
            verification_levels = {
              receive = "cross-signed-tofu";
              send = "cross-signed-tofu";
              share = "cross-signed-tofu";
            };
          };

          username_template = "facebook_{userid}";

          permissions = {
            "@mib:${serverName}" = "admin";
            ${serverName} = "user";
          };
        };
      };
    };
  };

  users = makeSet
    (name: {
      groups.${name} = { };
      users.${name} = { group = name; isSystemUser = true; };
    })
    [
      "conduit"
      "mx-puppet-discord"
    ];

  age.secrets = {
    matrix-bridge-facebook.file = ../../secrets/matrix-bridge-facebook.age;
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
            recommendedProxySettings = true;
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
