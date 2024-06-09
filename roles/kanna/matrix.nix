{ lib, config, host, inputs, pkgs, ... }:
let
  serverName = "kanp.ai";
  matrixHostname = "matrix.${serverName}";
  matrixOnion = "kanpai62to6zlysno5fqlpp7mvu5p4qn4cs5ia4nr2tj2mhdibanwzid.onion";
  matrixEep = "matrix.kanpai.i2p";
  matrixEepB32 = "kanpaiehzmk6l3igtj3mznvyt5stg6r6m4elklhaqlqfbxgmsida.b32.i2p";

  mkWellknownServer = hostname: port: {
    "m.server" = "${hostname}:${toString port}";
  };
  wellknownServer = mkWellknownServer matrixHostname 443;
  wellknownServerTor = mkWellknownServer matrixOnion 80;
  wellknownServerI2P = mkWellknownServer matrixEepB32 80;

  mkWellknownClient = protocol: hostname: {
    "m.homeserver".base_url = "${protocol}://${hostname}";
    "org.matrix.msc3575.proxy".url = "${protocol}://${hostname}";
  };
  wellknownClient = mkWellknownClient "https" matrixHostname;
  wellknownClientTor = mkWellknownClient "http" matrixOnion;
  wellknownClientI2P = mkWellknownClient "http" matrixEepB32;

  wellknownSupport = {
    contacts = [
      {
        matrix_id = "@mib:kanp.ai";
        email_address = "mib@kanp.ai";
        role = "m.role.admin";
      }
      {
        matrix_id = "@mib:kanp.ai";
        email_address = "mib@kanp.ai";
        role = "m.role.admin";
      }
    ];
  };

  makeSet = maker: opts:
    lib.lists.foldl lib.attrsets.recursiveUpdate { }
      (map maker opts);

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

    # tor
    tor.relay.onionServices.matrix = {
      version = 3;
      secretKey = config.age.secrets.tor-matrix.path;
      map = map (port: { inherit port; target.port = 80; }) [ 80 443 8443 ];
      settings.HiddenServiceSingleHopMode = true;
    };

    i2pd.inTunnels.matrix-client = {
      enable = true;
      destination = matrixEepB32;
      port = 80;
      keys = "matrix-keys.dat";
    };

    # bridges
    postgresql =
      let
        dbs = [
          "mx-puppet-discord"
          "mautrix-facebook"
        ];
      in
      {
        ensureDatabases = dbs;
        ensureUsers = map (name: { inherit name; ensureDBOwnership = true; }) dbs;
      };

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
          user = ":name (Discord)";
          userOverride = ":displayname [#:name in :guild/:channel] (Discord)";
          room = ":name [:guild]";
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
    tor-matrix.file = ../../secrets/tor-matrix.age;
  };

  persist.directories =
    lib.optional cfg.enable
      {
        directory = "/var/lib/private/matrix-conduit";
        user = "conduit";
        group = "conduit";
        mode = "0770";
      } ++
    lib.optional cfg.enable {
      directory = "/var/lib/private/mx-puppet-discord";
      user = "mx-puppet-discord";
      group = "mx-puppet-discord";
      mode = "0755";
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

    virtualHosts =
      let
        mkRedirectEndpoint = { return = "307 'https://${serverName}'"; };
        mkProxyEndpoint = {
          recommendedProxySettings = true;
          proxyPass = "http://[::1]:${toString cfg.settings.global.port}$request_uri";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_buffering off;
            client_max_body_size ${toString cfg.settings.global.max_request_size};
          '';
        };
        mkWellknownEndpoint = wellknown: {
          extraConfig = ''
            default_type application/json;
            add_header Access-Control-Allow-Origin "*";
          '';
          return = "200 '${builtins.toJSON wellknown}'";
        };
      in
      {
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
            "/" = mkRedirectEndpoint;
            "/_matrix/" = mkProxyEndpoint;
          };
        };

        ${serverName} = {
          enableACME = true;
          forceSSL = true;

          locations = {
            "/".return = "444"; # no response
            "=/.well-known/matrix/server" = mkWellknownEndpoint wellknownServer;
            "=/.well-known/matrix/client" = mkWellknownEndpoint wellknownClient;
            "=/.well-known/matrix/support" = mkWellknownEndpoint wellknownSupport;
          };
        };
      } // makeSet
        ({ name, serverName, server, client }: {
          ${name} = {
            inherit serverName;

            listen = [{
              addr = "127.0.0.1";
              port = 80;
              ssl = false;
            }];

            extraConfig = ''
              merge_slashes off;
            '';

            locations = {
              "/" = mkRedirectEndpoint;
              "/_matrix/" = mkProxyEndpoint;
              "=/.well-known/matrix/server" = mkWellknownEndpoint server;
              "=/.well-known/matrix/client" = mkWellknownEndpoint client;
              "=/.well-known/matrix/support" = mkWellknownEndpoint wellknownSupport;
            };
          };
        })
        [
          { name = "matrix-tor"; serverName = matrixOnion; server = wellknownServerTor; client = wellknownClientTor; }
          { name = "matrix-i2p"; serverName = "~^(${matrixEep}|${matrixEepB32})$"; server = wellknownServerI2P; client = wellknownClientI2P; }
        ];
  };

  # conduit db debugging
  environment.systemPackages = [ pkgs.rocksdb.tools ];
}
