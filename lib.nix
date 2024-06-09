{ inputs, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;

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

          # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
          # i.e. `"23.11" = [ "hello-2.12.1" ];`
          permittedInsecurePackages = { };
        in
        rec {
          inherit inputs args;
          settings = import ./config.nix { inherit lib; };
          host = module;
          lib = nixpkgs-lib;
        } // nixpkgs-lib.attrsets.foldlAttrs
          (acc: name: input: acc // nixpkgs-lib.optionalAttrs
            (hasPrefix "nixpkgs-" name)
            {
              ${removePrefix "nix" name} =
                let
                  version = removePrefix "nixpkgs-" name;
                in
                if !permittedInsecurePackages ? ${version}
                then input.legacyPackages.${module.system}
                else
                  import input {
                    inherit (module) system;
                    config.permittedInsecurePackages = permittedInsecurePackages.${version};
                  };
            }
          )
          { }
          inputs;
    };

  lib = {
    inherit mkModule;
  };
in
lib
