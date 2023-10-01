let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };

  inherit (lib.attrsets) collect;
  inherit (lib.lists) flatten foldl foldr;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  foldKeys = builtins.foldl' (acc: m: acc ++ getKeys m) [ ];
  keys = foldKeys config.admins ++ foldKeys (collect (c: c ? name) config.machines);

  mkSecret = secret: secret // {
    publicKeys = keys;
  };

  traverse = set: names: builtins.mapAttrs
    (name: value:
      let
        prefix = foldr (acc: name: "${acc}-${name}") name names;
      in
      if builtins.isList value
      then map (secret: { name = "${prefix}-${secret.name}.age"; secret = secret // { inherit name; }; }) value
      else traverse value (names ++ [ name ])
    )
    set;

  secrets = { };
in
foldl
  (acc: secret: acc // { ${secret.name} = mkSecret secret.secret; })
{ }
  (flatten
    (collect
      (e: builtins.typeOf e == "list")
      (traverse secrets [ ])))
