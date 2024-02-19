{ ... }: {
  imports = [
    ./monitoring.nix
    ./matrix.nix
    ./website.nix
    ./hath.nix
    ./vpn.nix
  ];

  system.autoUpgrade.enable = false;

  /*
  services.kubernetes = {
    roles = [ "master" "node" ];
  };
  */
}
