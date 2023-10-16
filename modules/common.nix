{ host, ... }: {
  imports = [
    ./acme.nix
    ./impermanence.nix
    ./containers.nix
    ./security.nix
    ./ssh.nix
    ./nix.nix
    ./auto-upgrades.nix
    ./nginx.nix
    ./prometheus.nix
  ];

  system.name = host.name;
}
