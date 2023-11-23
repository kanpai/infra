{ lib, config, ... }:
let
  cfg = config.services.postgresql;
in
{
  services.postgresql.enable = lib.mkDefault (cfg.ensureUsers != [ ] || cfg.ensureDatabases != [ ]);

  persist.directories = lib.optional cfg.enable {
    directory = cfg.dataDir;
    user = "postgres";
    group = "postgres";
  };
}
