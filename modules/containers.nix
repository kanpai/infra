{ lib, config, ... }:
let
  virtualisationEnabled = config.virtualisation.podman.enable or config.virtualisation.docker.enable;
in
{
  persist.directories = lib.optional virtualisationEnabled {
    directory = "/var/lib/containers/storage";
    user = "root";
    group = "root";
  };
}
