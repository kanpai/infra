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
    binary-cache = lib.genAttrs [
      "kanna"
      "mewo"
      "muffin"
    ]
      (host: {
        private-key.machines = [ host ];
      });
    hentaiathome.key.machines = [ "kanna" ];
    i2p = {
      base.machines = [ "kanna" ];
      matrix.machines = [ "kanna" ];
    };
    matrix = {
      bridge.facebook.machines = [ "kanna" ];
      tor.machines = [ "kanna" ];
    };
    nextcloud.admin.password.machines = [ "kanna" ];
    terraria.env = { };
    vpn.preauth = { };
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
