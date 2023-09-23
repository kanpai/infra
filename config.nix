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

  admins = [
    {
      name = "mib";
      email = "mib@kanp.ai";
      ssh.key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGdxUQ7MjztW//KJLjg4AgtUXDP0zJvdoh4nHCAEX6wJzIc3laOpVfN9jO8pm8DcAiprmUoBB5GZmTWBmD6V9tfls2bQLFYi0X59Eh4RA2e/hlDTTNcAi4d67tSiN9Ea0qnsLrhPrtIFQu9ipGXWI3YYx7jtmw7sfHRxQDbHXHFVI3JO2XAikCBYxKoSt7mxVpbGbuLvjvT8l6mmcC9XC0NAN5aes8CuCHXTnWkO1YVCCwLTOKmF4UVMexqI3aLKHlYId7qKmGDA7DL7nP880TiKpRu75YOGYDDFlKkC1on7KyTz/0H1ObHv60Qj29g5Z8fXmNZtt0tSKtcVH1RyitrfdOarAZsUICxUqHgG7TMbOxJ4hyklPqHcRB/W5FU78fTgE+P9W1PpK2FTiTu8JexHvbMHFc1CuKv80sZRPcSA0JbWx9q/Ul4c/dQn4AfjFYI7LP53BvZFoH4mlVSaqNbC96XU0d5m8nnGdMa0AUjhHh9zToThVPkzGNFKbNfpJ6u0U/PHwHoVbhcAHRN45oqyeGXuJxdJNB2b019Yhu9dVKDt6B7D0HtN3GKuOpPk14wlEFO1quAThIjCIRtOUuJCkaZ4gOpzskDCRVAfSw2W4I1JGU0ZLfvIdkQkxUvMrQts40FEIFr1JKCAVO6ofO40r6vVxnap1+r5McHDaQmw== cardno:000F_9741A6B2";
    }
  ];

  machines = {
    muffin = {
      name = "muffin";
      system = "x86_64-linux";
      host = ./hosts/muffin;
      roles = [
        ./roles/muffin
        ./roles/tor/guard
        ./roles/monero
      ];
      ip = "77.33.92.93";
      ssh.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEZ6KQkaMArVbkhmY4GGE0yeACMBdoTYqgb7iZMoTkv";
    };

    kanna = {
      name = "kanna";
      system = "x86_64-linux";
      host = ./hosts/kanna;
      roles = [
        ./roles/kanna
        ./roles/tor/guard
        ./roles/monero
      ];
      ip = "51.159.211.57";
      ssh.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDr4Sn1cAQ+jQzwj9bL3VKkay9CuYFS6sftolhSbjGDp";
    };
  };

  clusters = { };
in
{
  inherit admins machines clusters;
}
