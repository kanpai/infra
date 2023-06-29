{ inputs, config, ... }:
let
  inherit (builtins) elemAt mapAttrs typeOf;
  lib = inputs.nixpkgs.lib;

  mkHost = host:
    lib.nixosSystem {
      inherit (host) system;
      specialArgs = {
        settings = host;
        modules = import ../modules;
        inherit inputs lib;
      };
      modules = with inputs; [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        host.host
      ] ++ host.roles;
    };

  recurseHosts = hosts:
    mapAttrs
      (name: value:
        if (value ? name) then mkHost value
        else recurseHosts value
      )
      hosts;

  hosts = recurseHosts config.machines;
in
hosts
