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

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = inputs@{ nixpkgs, conch, ... }:
    let
      lib = inputs.nixpkgs.lib // import ./lib.nix { inherit inputs; };

      config = import ./config.nix { inherit lib; };
    in
    conch.load [
      "x86_64-darwin"
      "x86_64-linux"
    ]
      ({ pkgs, ... }: {
        development.python.enable = true;
        operations = {
          terranix.enable = true;
          nixos-anywhere.enable = true;
          nixops = {
            enable = true;
            unstable = true;
          };
        };
        flake = {
          nixosConfigurations = import ./hosts { inherit lib config; };
          nixopsConfigurations = import ./networks { inherit inputs lib config; };
        };
      });
}
