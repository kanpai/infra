{ host, ... }: {
  imports = [
    ./acme.nix
    ./impermanence.nix
    ./security.nix
    ./ssh.nix
    ./auto-upgrades.nix
    ./nginx.nix
    ./prometheus.nix
    ./minecraft.nix
  ];

  system.name = host.name;
}
