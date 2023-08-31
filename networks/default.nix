{ inputs, lib, config, ... }:
let
  inherit (builtins) mapAttrs;

  mkNetwork = network:
    let
      machines = mapAttrs
        (_: machine: { host, ... }: {
          imports = [ (lib.mkModule machine) ];
          deployment.targetHost = host.ip;
        })
        network.machines;
    in
    {
      nixpkgs = inputs.nixpkgs;
      network = {
        storage.legacy.databasefile = "~/.nixops/deployments.nixops";
      } // network.network;
    } // machines;

  networkFromCluster = cluster: { };

  defaultNetwork = {
    network = {
      description = "All machines";
    };
    machines = config.machines;
  };
  networks = lib.recurse (c: c ? machines) mkNetwork ({
    default = defaultNetwork;
  } // mapAttrs (_: cluster: networkFromCluster cluster) config.clusters);
in
networks
