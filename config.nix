{ lib, inputs ? null }:
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

  mkAdmin = key: admin: recursiveUpdate admin { };
  mkInstaller = key: spec:
    let
      installer =
        if spec != { }
        then spec
        else {
          name = key;
          system = key;
          host = ./installers/${key};
        };
    in
    recursiveUpdate installer {
      name = "installer-${installer.name}";
      roles = installer.roles or [ ] ++ [
        ./installers/base
      ];
    };
  mkMachine = key: machine: recursiveUpdate machine {
    roles = machine.roles or [ ] ++ [
      ./modules/common.nix
    ];
  };

  admins = mapAttrs mkAdmin {
    mib = {
      name = "mib";
      email = "mib@kanp.ai";
      keys = {
        ssh = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGdxUQ7MjztW//KJLjg4AgtUXDP0zJvdoh4nHCAEX6wJzIc3laOpVfN9jO8pm8DcAiprmUoBB5GZmTWBmD6V9tfls2bQLFYi0X59Eh4RA2e/hlDTTNcAi4d67tSiN9Ea0qnsLrhPrtIFQu9ipGXWI3YYx7jtmw7sfHRxQDbHXHFVI3JO2XAikCBYxKoSt7mxVpbGbuLvjvT8l6mmcC9XC0NAN5aes8CuCHXTnWkO1YVCCwLTOKmF4UVMexqI3aLKHlYId7qKmGDA7DL7nP880TiKpRu75YOGYDDFlKkC1on7KyTz/0H1ObHv60Qj29g5Z8fXmNZtt0tSKtcVH1RyitrfdOarAZsUICxUqHgG7TMbOxJ4hyklPqHcRB/W5FU78fTgE+P9W1PpK2FTiTu8JexHvbMHFc1CuKv80sZRPcSA0JbWx9q/Ul4c/dQn4AfjFYI7LP53BvZFoH4mlVSaqNbC96XU0d5m8nnGdMa0AUjhHh9zToThVPkzGNFKbNfpJ6u0U/PHwHoVbhcAHRN45oqyeGXuJxdJNB2b019Yhu9dVKDt6B7D0HtN3GKuOpPk14wlEFO1quAThIjCIRtOUuJCkaZ4gOpzskDCRVAfSw2W4I1JGU0ZLfvIdkQkxUvMrQts40FEIFr1JKCAVO6ofO40r6vVxnap1+r5McHDaQmw== cardno:000F_9741A6B2"
        ];
        age = [
          "age1e007kgnn4e2g0mtzvy5vdepujzfkz6v6hqh6aqa4655l62jcpgnsxv769h"
        ];
        build = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKiXYfgWXvTSAVnBPBObPB31KtVQ2XfyRpGSHJr8GsO9 hamilton"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVLuvIz8TSxajOM1PyUGI3G6nylrsZo23EpdD4nSJ38 macadamia"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4gOgNmw46awzS4ohFvUmoZ+sM2ZJHEchnznsElc30q sakamoto"
        ];
      };
    };
  };

  installers = mapAttrs mkInstaller {
    x86_64-linux = { };
    raspberrypi = {
      name = "raspberrypi";
      system = "aarch64-linux";
      host = ./installers/raspberrypi;
    };
  };

  machines = mapAttrs mkMachine {
    muffin = {
      name = "muffin";
      system = "x86_64-linux";
      host = ./hosts/muffin;
      roles = [
        ./roles/muffin
        ./roles/remote-builder
        ./roles/tor/guard
      ];
      keys.ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/Xm/uSh6Ppy2lBtTr4ucw8mVBYWrqcDYLXmXN1XMTP"
      ];
    };

    kanna = {
      name = "kanna";
      system = "x86_64-linux";
      host = ./hosts/kanna;
      roles = [
        ./roles/kanna
        ./roles/remote-builder
        ./roles/tor/guard
        ./roles/monero
      ];
      keys.ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPgiVv9HzuP6HlCvJeUYdSsMCp60/0HSlkYw7YA80lVX"
      ];
    };

    mewo = {
      name = "mewo";
      system = "aarch64-linux";
      host = ./hosts/mewo;
      roles = [
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        ./roles/mewo
        ./roles/remote-builder
      ];
      keys.ssh = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtD5IqU+Y3RkZKxQYR5fXRugRensSihj7diYAIgxEdI"
      ];
    };
  };

  clusters = { };
in
{
  inherit admins installers machines clusters;
}
