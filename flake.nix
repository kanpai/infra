{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    conch = {
      url = "github:mibmo/conch";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixos-anywhere.follows = "nixos-anywhere";
      };
    };
    deploy-rs.url = "github:serokell/deploy-rs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = ""; # disable darwin depedencies since all hosts are linux
      };
    };
    nixos-anywhere = {
      url = "github:mibmo/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  outputs = inputs@{ self, nixpkgs, conch, deploy-rs, ... }:
    let
      lib = inputs.nixpkgs.lib // import ./lib.nix { inherit inputs; };

      config = import ./config.nix { inherit lib inputs; };
    in
    conch.load [
      "x86_64-darwin"
      "x86_64-linux"
    ]
      ({ system, pkgs, ... }: {
        packages = [
          inputs.agenix.packages.${system}.default
          inputs.disko.packages.${system}.default
          pkgs.deploy-rs
          pkgs.nixos-generators
        ];
        development.python.enable = true;
        operations = {
          terranix.enable = true;
          nixos-anywhere.enable = true;
        };
        flake = {
          nixosConfigurations = import ./hosts { inherit lib config; };
          deploy = {
            sshUser = "root";
            sshOpts = [ "-p" "12248" ];

            nodes = builtins.foldl'
              (acc: machine: acc // {
                ${machine.name} = {
                  hostname = "${machine.name}.host.kanp.ai";
                  profiles.system.path = deploy-rs.lib.${machine.system}.activate.nixos self.nixosConfigurations.${machine.name};
                };
              })
              { }
              (lib.attrsets.collect (m: m ? name) config.machines);
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        };
      });
}
