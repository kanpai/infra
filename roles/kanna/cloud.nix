{ pkgs, pkgs-23_05, lib, config, settings, ... }:
let
  serverName = "cloud.kanp.ai";

  adminName = "mib";
  adminPasswordFile = config.age.secrets.nextcloud-admin-password.path;

  apps = {
    inherit (cfg.package.packages.apps)
      bookmarks
      calendar
      contacts
      cookbook
      cospend
      gpoddersync
      phonetrack
      previewgenerator
      ;
  };

  cfg = config.services.nextcloud;
in
lib.mkIf true {
  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;

      hostName = serverName;
      https = true;

      appstoreEnable = false;
      autoUpdateApps.enable = true;

      extraApps = apps;

      caching = {
        apcu = true; # local memcache
        redis = true; # file lock and distributed cache
      };

      maxUploadSize = "32G";

      config = {
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        adminuser = adminName;
        adminpassFile = adminPasswordFile;
      };

      # repeated string caching
      phpOptions."opcache.interned_strings_buffer" = 32;

      settings = {
        default_phone_region = "DK";
        maintenance_window_start = 1; # UTC 01:00
        "memcache.local" = ''\OC\Memcache\APCu'';
        "memcache.locking" = ''\OC\Memcache\Redis'';
        "memcache.distributed" = ''\OC\Memcache\Redis'';
      };
    };

    postgresql = {
      ensureDatabases = [ cfg.config.dbname ];
      ensureUsers = [{ name = cfg.config.dbuser; ensureDBOwnership = true; }];
    };

    redis.servers.nextcloud = {
      enable = true;
      user = "nextcloud";
    };

    nginx = {
      enable = true;
      virtualHosts = {
        "${serverName}" = {
          useACMEHost = serverName;
          forceSSL = true;
        };
        "www.${serverName}" = {
          useACMEHost = serverName;
          locations."/".return = "207 https://${serverName}";
        };
      };
    };
  };

  users = {
    users.nextcloud = {
      isSystemUser = true;
      group = "nextcloud";
    };
    groups.nextcloud = { };
  };

  security.acme.certs.${serverName}.extraDomainNames = [ "www.${serverName}" ];

  age.secrets.nextcloud-admin-password = {
    file = ../../secrets/nextcloud-admin-password.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  persist.directories = [{
    directory = cfg.datadir;
    user = "nextcloud";
    group = "nextcloud";
  }];

  # add nextcloud-occ package
  # to use, first `sh nextcloud --shell $(which sh)`, then `nextcloud-occ ...`
  environment.systemPackages = [ cfg.occ ];
}
