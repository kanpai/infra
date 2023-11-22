{ lib, config, ... }:
let
  cfg = config.services.tor;
in
{
  services.tor =
    let
      onions = builtins.attrValues cfg.relay.onionServices;
      anyOnions = builtins.length onions > 0;
      nonAnonymous = builtins.any (os: os.settings.HiddenServiceSingleHopMode == true) onions;
    in
    {
      enable = lib.mkDefault anyOnions;
      settings.HiddenServiceNonAnonymousMode = lib.mkDefault nonAnonymous;
    };

  persist.directories = lib.optional cfg.enable {
    directory = cfg.settings.DataDirectory;
    user = "tor";
    group = "tor";
  };
}
