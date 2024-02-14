{ lib, config, ... }:
let
  mkHost = host:
    lib.nixosSystem {
      inherit (host) system;
      modules = [ (lib.mkModule host) ];
    };

  hosts = builtins.foldl'
    (acc: machine: acc // { ${machine.name} = mkHost machine; })
    { }
    (lib.attrsets.collect (c: c ? name) (config.machines // config.installers));
in
hosts
