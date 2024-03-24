{ host, ... }:
{
  imports = [
    ./disks.nix
    ./networking.nix
  ];

  nixpkgs.hostPlatform = host.system;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        copyKernels = false;
        configurationLimit = 3;
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
