{ host, inputs, ... }:
{
  imports = [
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./disks.nix
    ./networking.nix
  ];

  nixpkgs.hostPlatform = host.system;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 3;
      };
    };
  };

  services.openssh.settings.PermitRootLogin = "yes";

  i18n.defaultLocale = "en_DK.UTF-8";

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
