{ lib, inputs, config, settings, ... }:
{
  networking = {
    usePredictableInterfaceNames = lib.mkForce true;
    hostName = "nixos-installer";
  };

  services.openssh = {
    enable = true;
    ports = [ 12248 ];
    settings.PermitRootLogin = "yes";
  };

  users.users.root.openssh.authorizedKeys.keys = builtins.foldl' (acc: admin: acc ++ admin.keys.ssh) [ ] settings.admins;

  system.stateVersion = config.system.nixos.release;

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
