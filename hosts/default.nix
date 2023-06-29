{ lib, config, ... }:
let
  mkHost = host:
    lib.nixosSystem {
      inherit (host) system;
      modules = [ (lib.mkModule host) ];
    };

  hosts = lib.recurse (c: c ? name) mkHost config.machines;
in
hosts
