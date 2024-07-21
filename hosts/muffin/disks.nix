{ lib, ... }:
let
  systemDisk = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_250GB_S3ESNX0K324093D"; # 250gb
  dataDisk = "/dev/disk/by-id/ata-ST3000DM008-2DM166_Z504ZZHD"; # 3tb

  mkDisk = { device, content, ... }: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          type = "EF02";
          size = "1M";
          priority = 1;
        };
        ESP = {
          type = "EF00";
          size = "1G";
          content = {
            type = "mdraid";
            name = "boot";
          };
        };
        data = { size = "100%"; inherit content; };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      system = mkDisk {
        device = systemDisk;
        content = {
          type = "filesystem";
          format = "bcachefs";
          mountpoint = "/nix";
          mountOptions = [ "noatime" ];
        };
      };

      data = mkDisk {
        device = dataDisk;
        content = {
          type = "filesystem";
          format = "bcachefs";
          mountpoint = "/persist";
          mountOptions = [ "noexec" ];
        };
      };
    };

    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "noexec" ];
        };
      };
    };

    nodev."/" = {
      fsType = "ramfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
