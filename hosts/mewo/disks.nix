{ ... }:
let
  disks = [
    #"/dev/sdb"
    "/dev/disk/by-diskseq/9"
  ];

  mkDisk = { device, ... }: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "256M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        nix = {
          size = "8G";
          content = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/nix";
          };
        };
        persist = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/persist";
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
  };

  fileSystems."/persist".neededForBoot = true;
}
