{ ... }:
let
  disks = [
    { name = "main"; device = "/dev/disk/by-id/usb-SanDisk_Cruzer_Blade_4C532000060330111390-0:0"; }
  ];

  mkDisk = { device, ... }: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "512M";
          type = "EF00";
          priority = 0;
          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-F32" ];
            mountpoint = "/boot";
            mountOptions = [ "noexec" ];
          };
        };
        nix = {
          size = "10G";
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
            mountOptions = [ "noexec" ];
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = builtins.foldl' (acc: entry: acc // { ${entry.name} = mkDisk entry; }) { } disks;

    nodev."/" = {
      fsType = "ramfs";
      mountOptions = [
        "defaults"
        "mode=755"
        "noexec"
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
