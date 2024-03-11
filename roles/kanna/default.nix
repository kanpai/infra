{ ... }: {
  imports = [
    ./monitoring.nix
    ./matrix.nix
    ./website.nix
    ./hath.nix
    ./vpn.nix
    ./cloud.nix
    ./mail.nix
  ];

  system.autoUpgrade.enable = false;

  /*
  services.kubernetes = {
    roles = [ "master" "node" ];
  };
  */
}
