{ ... }: {
  imports = [
    ../relay.nix
  ];

  services.tor.relay = {
    enable = true;
    role = "relay";
  };
}
