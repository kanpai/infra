{ settings, ... }: {
  imports = [
    ./impermanence.nix
    ./ssh.nix
    ./auto-upgrades.nix
    ./clamav.nix
  ];

  system.name = settings.name;
}
