{ ... }:
let
  disks = [
    "/dev/sda"
    "/dev/sdb"
  ];

  mkDisk = { device, ... }: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          type = "EF02";
          size = "1M";
        };
        ESP = {
          type = "EF00";
          size = "128M";
          content = {
            type = "mdraid";
            name = "boot";
          };
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
    disk = builtins.foldl' (acc: disk: acc // { ${disk} = mkDisk { device = disk; }; }) { } disks;

    nodev."/" = {
      fsType = "ramfs";
      mountOptions = [
        "defaults"
        "mode=755"
      ];
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

    zpool = {
      data = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        postCreateHook = "zfs snapshot data@blank";

        datasets = {
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          persist = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
            mountOptions = [ "noexec" ];
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
