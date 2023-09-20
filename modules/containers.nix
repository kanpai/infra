{ lib, config, ... }: {
  persist.directories = lib.optional {
    directory = "/var/lib/containers/storage";
    user = "root";
    group = "root";
  };
}
