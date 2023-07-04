{ settings, ... }: {
  imports = [
    ./impermanence.nix
    ./security.nix
    ./ssh.nix
    ./auto-upgrades.nix
    ./minecraft.nix
  ];

  system.name = settings.name;
}
