{ inputs, settings, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;

  inherit (builtins) replaceStrings;
  inherit (nixpkgs-lib.attrsets) attrValues foldlAttrs optionalAttrs;
  inherit (nixpkgs-lib.lists) flatten;
  inherit (nixpkgs-lib.strings) hasPrefix removePrefix;

  setIf = key: cond: if cond then key else null;

  getKeys = configType: keyTypes:
    flatten (map (m: map (type: m.keys.${type} or [ ]) keyTypes) (attrValues settings.${configType}));

  mkModule = host:
    args@{ ... }: {
      imports = with inputs; [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        agenix.nixosModules.age
        host.host
      ] ++ host.roles;

      _module.args =
        let
          # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
          # i.e. `"23.11" = [ "hello-2.12.1" ];`
          permittedInsecurePackages = { };

          overlays = import ./overlays { inherit inputs host; lib = stripped-lib; };
        in
        {
          inherit inputs args host;
          settings = import ./config.nix { lib = stripped-lib; };
          klib = stripped;
        } // foldlAttrs
          (acc: name: input: acc // optionalAttrs
            (hasPrefix "nixpkgs-" name)
            {
              ${removePrefix "nix" name} =
                let
                  version = replaceStrings [ "_" ] [ "." ] (removePrefix "nixpkgs-" name);
                  hasInsecureOverride = permittedInsecurePackages ? ${version};
                  hasOverlays = overlays ? ${version};
                in
                if hasInsecureOverride || hasOverlays
                then
                  import input
                    {
                      inherit (host) system;
                      ${setIf "overlays" hasOverlays} = overlays.${version};
                      config = {
                        ${setIf "permittedInsecurePackages" hasInsecureOverride} = permittedInsecurePackages.${version};
                      };
                    }
                else input.legacyPackages.${host.system};
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
