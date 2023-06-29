{ inputs, ... }:
let
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
        module.host
      ] ++ module.roles;

      _module.args = {
        settings = module;
        modules = ../modules;
        lib = inputs.nixpkgs.lib // lib;
        inherit inputs args;
      };
    };

  lib = {
    inherit recurse mkModule;
  };
in
lib
