{ lib, pkgs, inputs, config, settings, ... }:
{
  networking = {
    networkmanager.enable = true;
    wireless.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    hostName = "nixos-installer";
  };

  services.openssh = {
    enable = true;
    ports = [ 12248 ];
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users.root = {
    password = "toor";
    openssh.authorizedKeys.keys = builtins.foldl' (acc: admin: acc ++ admin.keys.ssh) [ ] settings.admins;
  };

  system.stateVersion = config.system.nixos.release;

  nix = {
    settings.experimental-features = [ "flakes" "nix-command" ];
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
