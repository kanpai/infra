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
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "kvm-amd" ];
    initrd = {
      availableKernelModules = [ "xhci_pci" "xhci_hcd" "ahci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = false;
        configurationLimit = 5;
      };
    };
    swraid.enable = true;
  };

  powerManagement.cpuFreqGovernor = "performance";

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
