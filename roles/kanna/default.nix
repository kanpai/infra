{ ... }: {
  imports = [
    ./monitoring.nix
    ./matrix.nix
    ./website.nix
  ];

  system.autoUpgrade.enable = false;

  /*
  services.kubernetes = {
    roles = [ "master" "node" ];
  };
  */
}
