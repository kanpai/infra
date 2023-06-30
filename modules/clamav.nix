{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.services.clamav;
in
{
  options.services.clamav = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ClamAV suite";
    };

    interval = mkOption {
      type = types.str;
      default = "2hour";
      description = ''
        How often to scan the filesystem for viruses.
        Follows the systemd timer format
      '';
    };
  };

  config = mkIf cfg.enable {
    services.clamav = {
      daemon = {
        enable = mkDefault false;
        settings = {
          LocalSocket = "/run/clamav/clamd.ctl";
        };
      };
      updater.enable = true;
    };

    # automatic scanning
    systemd = {
      services.clamav-scan = {
        description = "Scan filesystems using ClamAV";
        after = [ "clamav-freshclam.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.clamav}${if cfg.daemon.enable then "/bin/clamdscan --multiscan" else "/bin/clamscan" } \
              --recursive \
              --infected \
              /nix /persist
          '';
          SuccessExitStatus = "0"; # no viruses found
        };
      };

      timers.clamav-scan = {
        description = "Timer for performing a full system scan";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "clamav-scan.service";
          OnBootSec = "5min"; # run 5 min after boot
          OnUnitActiveSec = cfg.interval; # and then every interval
        };
      };
    };
  };
}
