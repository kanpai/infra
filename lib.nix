{ inputs, settings, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;

  inherit (nixpkgs-lib.attrsets) attrValues foldlAttrs optionalAttrs;
  inherit (nixpkgs-lib.lists) flatten;
  inherit (nixpkgs-lib.strings) hasPrefix removePrefix;

  setIf = key: cond: if cond then key else null;

  getKeys = configType: keyTypes:
    flatten (map (m: map (type: m.keys.${type} or [ ]) keyTypes) (attrValues settings.${configType}));

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
          # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
          # i.e. `"23.11" = [ "hello-2.12.1" ];`
          permittedInsecurePackages = { };
        in
        rec {
          inherit inputs args;
          settings = import ./config.nix { lib = stripped-lib; };
          host = module;
          klib = stripped;
        } // foldlAttrs
          (acc: name: input: acc // optionalAttrs
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

  stripped = {
    inherit getKeys setIf;
  };
  stripped-lib = nixpkgs-lib // stripped;

  full = stripped // { inherit mkModule; };
in
full
