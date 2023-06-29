{ settings, ... }:
{
  imports = [
    ./disks.nix
    ./networking.nix
  ];

  nixpkgs.hostPlatform = settings.system;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "xhci_hcd" "ahci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };
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
    persistentStoragePath = "/persist";
    directories = [
      "/var/logs"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  networking.hostName = settings.name;

  system.stateVersion = "23.11";
}
