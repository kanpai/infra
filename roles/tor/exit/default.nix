{ ... }: {
  imports = [
    ../relay.nix
  ];

  services.tor = {
    relay = {
      enable = true;
      role = "exit";
    };
    settings.ExitPolicy = [
      "accept *:*"
    ];
  };
}
