{ ... }: {
  imports = [
    ./monitoring.nix
    ./gameserver.nix
  ];

  system.autoUpgrade.enable = false;
}
