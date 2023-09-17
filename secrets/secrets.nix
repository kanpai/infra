let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };
  getKey = m: m.ssh.key;
  keys = map getKey config.admins ++ lib.attrsets.attrValues (lib.recurse (c: c ? name) getKey config.machines);
  mkSecret = secret: secret // {
    publicKeys = keys;
  };
in
{ }
