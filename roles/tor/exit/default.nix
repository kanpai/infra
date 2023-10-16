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
      "reject *:25" # smtp
      "reject *:465" # url rendesvous directory for SSM (cisco protocol)
      "reject *:587" # secure smtp
    ];
  };
}
