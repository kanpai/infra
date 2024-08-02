{ ... }:
let
  disks = {
    main = { device = "/dev/disk/by-id/ata-Intenso_SSD_Sata_III_AA000000000000010250"; };
  };

  mkDisk = { device, ... }: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          priority = 0;
          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-F32" ];
            mountpoint = "/boot";
            mountOptions = [ "noexec" ];
            postMountHook = ''
              # copy over firmware filesystem
              mkdir --parents /mnt/firmware
              mount /dev/disk/by-label/FIRMWARE /mnt/firmware
              find /mnt/firmware -maxdepth 1 \
                -execdir cp /mnt/{firmware,boot}/{} \;
            '';
          };
        };
        swap = {
          size = "8G";
          priority = 1;
          content.type = "swap";
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "data";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = builtins.mapAttrs (_: mkDisk) disks;

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
    };

    zpool.data = {
      type = "zpool";
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false";
      };

      datasets = {
        nix = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/nix";
          mountOptions = [ "noatime" ];
        };
        persist = {
          type = "zfs_fs";
          options.mountpoint = "legacy";
          mountpoint = "/persist";
          mountOptions = [ "noexec" ];
          postMountHook = ''
            # copy over host keys
            mkdir --parents --mode=755 /mnt/persist/etc/ssh
            find /etc/ssh/ -type f -name "ssh_host_*_key" \
              -execdir cp {,/mnt/persist}/etc/ssh/{} \;
          '';
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
