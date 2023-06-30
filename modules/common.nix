{ settings, ... }: {
  imports = [
    ./impermanence.nix
    ./security.nix
    ./ssh.nix
    ./auto-upgrades.nix
    ./clamav.nix
  ];

  system.name = settings.name;
}
