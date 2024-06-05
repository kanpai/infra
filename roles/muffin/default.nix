{ pkgs, settings, ... }:
{
  imports = [
    ./terraria.nix
  ];

  system.autoUpgrade.enable = false;
}
