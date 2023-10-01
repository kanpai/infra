{ ... }: {
  imports = [
    ./monitoring.nix
    ./matrix.nix
    ./gameserver.nix
  ];

  system.autoUpgrade.enable = false;

  /*
  services.kubernetes = {
    roles = [ "master" "node" ];
  };
  */
}
