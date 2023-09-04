{ config, lib, ... }:
let
  cfg = config.services.monero;
in
{
  services.monero = lib.mkDefault {
    enable = true;
    rpc = {
      address = "0.0.0.0";
      restricted = true;
    };
    extraConfig = ''
      public-node=1
      confirm-external-bind=1
    '';
  };

  networking.firewall.allowedTCPPorts = [
    18080
    cfg.rpc.port
  ];

  persist.directories = lib.optional cfg.enable {
    directory = cfg.dataDir;
    user = "monero";
    group = "monero";
  };
}
