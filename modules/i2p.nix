{ lib, config, ... }:
let
  cfg = config.services.i2pd;
  tunnels = (builtins.attrValues cfg.inTunnels) ++ (builtins.attrValues cfg.outTunnels);
in
{
  services.i2pd = {
    enable = lib.mkDefault (builtins.any (tunnel: tunnel.enable) tunnels);
  };

  persist.directories = lib.optional cfg.enable {
    directory = if !builtins.isNull cfg.dataDir then cfg.dataDir else "/var/lib/i2pd";
    user = "i2pd";
    group = "i2pd";
  };
}
