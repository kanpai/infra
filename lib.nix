{ inputs, settings, ... }:
let
  nixpkgs-lib = inputs.nixpkgs.lib;

  inherit (builtins) head replaceStrings;
  inherit (nixpkgs-lib.attrsets) attrNames attrValues filterAttrs mapAttrs mapAttrs';
  inherit (nixpkgs-lib.lists) flatten;
  inherit (nixpkgs-lib.strings) hasPrefix removePrefix;
  inherit (nixpkgs-lib.trivial) pipe;

  # set key in attribute set based on condition
  # usage: {
  #  ${setIf "favourites" hasFavourites} = favourites;
  # }
  setIf = key: cond: if cond then key else null;

  # get keys of certain types from the config
  # usage: `getKeys 'admins" [ "ssh" "build" ]` gets ssh and build keys from the configured admins
  getKeys = configType: keyTypes:
    flatten (map (m: map (type: m.keys.${type} or [ ]) keyTypes) (attrValues settings.${configType}));

  mkModule = host:
    let
      # "release" = [ "pkgs-0.1.0" "to-0.2.0" "allow-0.3.0];
      # i.e. `"23.11" = [ "hello-2.12.1" ];`
      permittedInsecurePackages = { };

      # turn `nixpkgs-24_05` into `24.05`
      inputNixpkgsToVersion = name: replaceStrings [ "_" ] [ "." ] (removePrefix "nixpkgs-" name);
      overlays = import ./overlays { inherit inputs host; lib = stripped-lib; };
      nixpkgs' = filterAttrs (name: _: hasPrefix "nixpkgs-" name) inputs;
      packageSets =
        mapAttrs
          (name: input:
            let
              version = inputNixpkgsToVersion name;
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
            else input.legacyPackages.${host.system}
          )
          nixpkgs';
      # release of nixpkgs that modules are built with
      moduleNixpkgsVersion = pipe nixpkgs' [
        (filterAttrs (name: input: input.rev == inputs.nixpkgs.rev && name != "nixpkgs-stable"))
        attrNames
        head
        inputNixpkgsToVersion
      ];
    in
    args@{ ... }: {
      imports = with inputs; [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        agenix.nixosModules.age
        host.host
      ] ++ host.roles;

      _module.args = {
        inherit inputs args host;
        settings = import ./config.nix { lib = stripped-lib; };
        klib = stripped;
      } // mapAttrs'
        (name: value: {
          name = removePrefix "nix" name;
          inherit value;
        })
        packageSets;

      nixpkgs.overlays = overlays.${moduleNixpkgsVersion} or [ ];
    };

  stripped = {
    inherit getKeys setIf;
  };
  stripped-lib = nixpkgs-lib // stripped;

  full = stripped // { inherit mkModule; };
in
full
