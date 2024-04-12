{ config, ... }:
let
  cfg = config.services.home-assistant;
in
{
  services.home-assistant = {
    enable = true;
    config = null; # todo
    extraComponents = [
      "zeroconf"
      "zha"
      "tradfri"
    ];
    extraPackages = pkgs: with pkgs; [
      numpy
      dateutil
    ];
  };

  persist.directories = [{
    directory = cfg.configDir;
    user = "hass";
    group = "hass";
  }];
}
