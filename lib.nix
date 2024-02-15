{ inputs, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;

  recurse = pred: f: set:
    builtins.mapAttrs
      (name: value:
        if pred value
        then f value
        else recurse pred f value
      )
      set;

  mkModule = module:
    args@{ ... }: {
      imports = with inputs; [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        agenix.nixosModules.age
        module.host
      ] ++ module.roles;

      _module.args =
        let
          inherit (nixpkgs-lib.strings) hasPrefix removePrefix;
        in
        rec {
          inherit inputs args;
          settings = import ./config.nix { inherit lib; };
          host = module;
          modules = ../modules;
          lib = nixpkgs-lib // lib;
        } // nixpkgs-lib.attrsets.foldlAttrs
          (acc: name: input: acc // nixpkgs-lib.optionalAttrs
            (hasPrefix "nixpkgs-" name)
            { ${removePrefix "nix" name} = input.legacyPackages.${module.system}; }
          )
          { }
          inputs;
    };

  lib = {
    inherit recurse mkModule;
  };
in
lib
