{ lib }:
let
  inherit (lib.lists) count range zipListsWith;
  inherit (lib.attrsets) mapAttrs recursiveUpdate;
  length = count (_: true);
  rangeTo = range 1;

  # maker func must return an attribute set with `name` set to a string
  genMachines = maker: configs:
    builtins.foldl' recursiveUpdate
      { }
      (map
        (machine: { ${machine.name} = machine; })
        (zipListsWith maker (rangeTo (length configs)) configs));

  mkMachine = machine: machine;

  secrets = {
    ssh = {
      bootstrap = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILof6lu+/Kd8bVgVgFKVhYIrjwHS+IFenacH/tdrkN8/";
    };
  };

  machines = {
    muffin = {
      name = "muffin";
      system = "x86_64-linux";
      host = ./hosts/muffin;
      roles = [ ./roles/muffin ];
      ip = "77.33.92.93";
    };
  };

  clusters = { };
in
{
  inherit secrets;
  inherit machines;
  inherit clusters;
}
