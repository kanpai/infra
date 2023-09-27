{ ... }: {
  imports = [
    ./monitoring.nix
  ];

  system.autoUpgrade.enable = false;
}
