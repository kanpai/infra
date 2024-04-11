{
  inputs = {
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-stable.follows = "nixpkgs-23_11";

    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-23_11.url = "nixpkgs/nixos-23.11";
    nixpkgs-23_05.url = "nixpkgs/nixos-23.05";

    conch = {
      url = "github:mibmo/conch";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixos-anywhere.follows = "nixos-anywhere";
      };
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    conduit.url = "gitlab:famedly/conduit/next";
  };
  outputs = inputs@{ self, nixpkgs, conch, ... }:
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
        development.python = {
          enable = true;
          package = pkgs.python311.withPackages (pkgs: with pkgs; [
            braceexpand
          ]);
        };
        operations = {
          terranix.enable = true;
          nixos-anywhere.enable = true;
        };
        shellHook = ''
          function _installers() {
            installers="$(basename --multiple ${./installers}/* | awk '$1 !~ "base" { print }')"
            COMPREPLY=($(compgen -W "$installers" -- ''${COMP_WORDS[$COMP_CWORD]}))
            return 0
          }

          complete -F _installers build-image 
        '';
        flake = {
          nixosConfigurations = import ./hosts { inherit lib config; };
          deploy = {
            sshUser = "root";
            sshOpts = [ "-p" "12248" ];

            nodes = builtins.foldl'
              (acc: machine: acc // {
                ${machine.name} =
                  let
                    deployPkgs = import nixpkgs {
                      system = machine.system;
                      overlays = [
                        inputs.deploy-rs.overlay
                        (self: super: {
                          deploy-rs = {
                            inherit (super.deploy-rs) lib;
                            deploy-rs =
                              if machine.system == pkgs.system
                              then pkgs.deploy-rs
                              else super.deploy-rs.deploy-rs;
                          };
                        })
                      ];
                    };
                  in
                  {
                    hostname = "${machine.name}.kanpai";
                    profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${machine.name};
                  };
              })
              { }
              (lib.attrsets.collect (m: m ? name) config.machines);
          };

          checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
        };
      });
}
