let
  lib = (import <nixpkgs/lib>) // (import ../lib.nix { inputs = { }; });
  config = import ../config.nix { inherit lib; };

  inherit (lib.attrsets) collect getAttrFromPath listToAttrs mapAttrsRecursiveCond;
  inherit (lib.strings) concatMapStringsSep splitString;
  inherit (lib.lists) flatten;

  getKeys = m: (m.keys.ssh or [ ]) ++ (m.keys.age or [ ]);
  intoKeys = configs: flatten (map getKeys configs);
  keysFromPath = type: path: getAttrFromPath (splitString "/" path) config.${type};
  collectKeys = set: collect (m: m ? "name") set;

  sanitize = lib.replaceStrings [ "-" ] [ "_" ];
  isEndpoint = set: set == { } || set ? "admins" || set ? "machines";

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
listToAttrs
  (collect
    (s: s ? "name")
    (mapAttrsRecursiveCond
      (s: !(isEndpoint s))
      (path: s: {
        name = concatMapStringsSep "-" sanitize path + ".age";
        value.publicKeys = flatten (map intoKeys [
          (if s ? "admins" then map (keysFromPath "admins") s.admins else collectKeys config.admins)
          (if s ? "machines" then map (keysFromPath "machines") s.machines else collectKeys config.machines)
        ]);
      })
      secrets
    )
  )
