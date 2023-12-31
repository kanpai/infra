{ host, pkgs, ... }:
{
  imports = [
    ./disks.nix
    ./networking.nix
    ./gpu.nix
  ];

  nixpkgs.hostPlatform = host.system;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "xhci_hcd" "ahci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        devices = [ "/dev/nvme0n1" ];
        efiSupport = true;
      };
    };
  };

  environment.persistence.main = {
    enable = true;
    persistentStoragePath = "/persist";
    directories = [
      "/var/log"
      "/var/logs"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  system.stateVersion = "23.11";
}
