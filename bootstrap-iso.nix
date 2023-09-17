{ lib, ... }:
let
  config = import ./config.nix { inherit lib; };
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  services.openssh = {
    enable = true;
    ports = [ 12248 ];
    settings.PermitRootLogin = "yes";
  };
  users.users.root.openssh.authorizedKeys.keys = map (admin: admin.ssh.key) config.admins;

  networking = {
    usePredictableInterfaceNames = lib.mkForce true;
    hostName = "nixos";
  };

  isoImage.squashfsCompression = "lz4";
}
