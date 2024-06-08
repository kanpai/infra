let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };

  inherit (lib.attrsets) collect recursiveUpdate;
  inherit (lib.lists) foldl foldr;
  inherit (builtins) typeOf mapAttrs;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  foldKeys = foldl (acc: m: acc ++ getKeys m) [ ];
  keys = foldKeys config.admins ++ foldKeys (collect (c: c ? name) config.machines);

  traverse =
    let
      sanitize = lib.replaceStrings [ "-" ] [ "_" ];
    in
    set: names: mapAttrs
      (name: value:
        if value == { }
        then foldr (acc: name: "${acc}-${name}") (sanitize name) names + ".age"
        else traverse value (names ++ [ (sanitize name) ])
      )
      set;

  secrets = {
    i2p = {
      base = { };
      matrix = { };
    };
    terraria.env = { };
    matrix = {
      tor = { };
      bridge.facebook = { };
    };
    vpn.preauth = { };
    hentaiathome.key = { };
    nextcloud.admin.password = { };
    binary-cache = lib.genAttrs [
      "kanna"
      "mewo"
      "muffin"
    ]
      (_: { private-key = { }; });
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
