let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };

  inherit (lib.attrsets) collect getAttrFromPath recursiveUpdate;
  inherit (lib.strings) splitString;
  inherit (lib.lists) flatten foldl foldr;
  inherit (builtins) mapAttrs;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  intoKeys = configs: flatten (map getKeys configs);
  keysFromPath = type: path: getAttrFromPath (splitString "/" path) config.${type};
  collectKeys = set: collect (m: m ? "name") set;

  traverse =
    let
      sanitize = lib.replaceStrings [ "-" ] [ "_" ];
      isEndpoint = set: set == { } || set ? "admins" || set ? "machines";
    in
    set: names: mapAttrs
      (name: value:
        if isEndpoint value
        then value // {
          filename = foldr (acc: name: "${acc}-${name}") (sanitize name) names + ".age";
        }
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
      (host: {
        private-key.machines = [ host ];
      });
  };
in
foldl recursiveUpdate { }
  (map
    (s: {
      ${s.filename} = {
        publicKeys = lib.flatten (map intoKeys [
          (if s ? "admins" then map (keysFromPath "admins") s.admins else collectKeys config.admins)
          (if s ? "machines" then map (keysFromPath "machines") s.machines else collectKeys config.machines)
        ]);
      };
    })
    (collect
      (secret: secret ? filename)
      (traverse secrets [ ])))
