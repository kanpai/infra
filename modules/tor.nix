{ lib, config, ... }:
let
  cfg = config.services.tor;
in
{
  services.tor = {
    enable = lib.mkDefault (builtins.length (builtins.attrValues cfg.relay.onionServices) > 0);
    settings.HiddenServiceNonAnonymousMode = true;
  };

  persist.directories = lib.optional cfg.enable {
    directory = cfg.settings.DataDirectory;
    user = "tor";
    group = "tor";
  };
}
