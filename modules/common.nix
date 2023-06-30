{ ... }: {
  imports = [
    ./impermanence.nix
    ./ssh.nix
    ./auto-upgrades.nix
    ./clamav.nix
  ];
}
