{ ... }: {
  imports = [
    ./monitoring.nix
    ./matrix.nix
    ./website.nix
    ./gameserver.nix
  ];

  system.autoUpgrade.enable = false;

  /*
  services.kubernetes = {
    roles = [ "master" "node" ];
  };
  */
}
