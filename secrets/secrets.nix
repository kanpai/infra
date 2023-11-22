let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };

  inherit (lib.attrsets) collect recursiveUpdate;
  inherit (lib.lists) foldl foldr;
  inherit (builtins) typeOf mapAttrs;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  foldKeys = foldl (acc: m: acc ++ getKeys m) [ ];
  keys = foldKeys config.admins ++ foldKeys (collect (c: c ? name) config.machines);

  traverse = set: names: mapAttrs
    (name: value:
      if value == { }
      then foldr (acc: name: "${acc}-${name}") name names + ".age"
      else traverse value (names ++ [ name ])
    )
    set;

  secrets = {
    terraria.env = { };
  };
in
foldl
  recursiveUpdate
{ }
  (map
    (filename: { ${filename} = { publicKeys = keys; }; })
    (collect
      (secret: typeOf secret == "string")
      (traverse secrets [ ])))
