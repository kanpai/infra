{ lib, ... }:
let
  allDevices = [ boot ] ++ dataPool ++ systemPool;
  encryptedDevices = allDevices;
  boot = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_250GB_S3ESNX0K324093D"; # 250gb
  dataPool = [
    "/dev/disk/by-id/ata-ST3000DM008-2DM166_Z504ZZHD" # 3tb
    "/dev/disk/by-id/ata-WDC_WD10EZEX-60M2NA0_WD-WCC3F5RHXELK" # 1tb
    "/dev/disk/by-id/ata-SAMSUNG_HD103SI_S2ADJ1CZ303130" # 1tb
    "/dev/disk/by-id/ata-WDC_WD3200AAJS-00L7A0_WD-WMAV2C253029" # 300gb
  ];
  systemPool = [
    "/dev/disk/by-id/ata-Intenso_SSD_Sata_III_AA000000000000010250" # 250gb
  ];

  keyFile = "/dev/disk/by-partuuid/c199ee0c-9e34-4915-ac6e-b8a1241afcc9";

  nameFromDevice = device: "crypt-" + lib.lists.last (lib.strings.splitString "/" device);

  mkPoolPv = { start, end, vg, device, ... }: {
    name = "luks";
    inherit start end;
    content = {
      type = "luks";
      name = nameFromDevice device;
      extraOpenArgs = [ "--allow-discards" ];
      inherit keyFile;
      content = {
        type = "lvm_pv";
        inherit vg;
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      "${boot}" = {
        device = boot;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "1M";
              flags = [ "bios_grub" ];
            }
            {
              name = "ESP";
              start = "1MiB";
              end = "100MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "swap";
              start = "100MiB";
              end = "32GiB";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            }
            (mkPoolPv { vg = "system"; device = boot; start = "32GiB"; end = "100%"; })
          ];
        };
      };
    } // lib.genAttrs dataPool (device: {
      inherit device;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          (mkPoolPv { vg = "data"; inherit device; start = "0"; end = "100%"; })
        ];
      };
    }) // lib.genAttrs systemPool (device: {
      inherit device;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          (mkPoolPv { vg = "system"; inherit device; start = "0"; end = "100%"; })
        ];
      };
    });

    lvm_vg = {
      data = {
        type = "lvm_vg";
        lvs = {
          data = {
            size = "2T";
            content = {
              type = "filesystem";
              format = "ext4";
            };
          };
        };
      };
      system = {
        type = "lvm_vg";
        lvs = {
          nix = {
            size = "400G";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/nix";
            };
          };
          persist = {
            size = "5G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;

  boot.initrd.luks.devices =
    builtins.foldl'
      lib.recursiveUpdate
      { }
      (map
        (device: {
          ${nameFromDevice device} = {
            inherit keyFile;
          };
        })
        encryptedDevices);
}
