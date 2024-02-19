{ host, ... }: {
  imports = [
    ./acme.nix
    ./age.nix
    ./clamav.nix
    ./impermanence.nix
    ./containers.nix
    ./security.nix
    ./ssh.nix
    ./nix.nix
    ./auto-upgrades.nix
    ./nginx.nix
    ./prometheus.nix
    ./tor.nix
    ./i2p.nix
    ./postgresql.nix
    ./vpn.nix
  ];

  system.name = host.name;
}
