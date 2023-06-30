{ settings, ... }: {
  imports = [
    ./impermanence.nix
    ./security.nix
    ./ssh.nix
    ./auto-upgrades.nix
  ];

  system.name = settings.name;
}
