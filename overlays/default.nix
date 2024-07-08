# mapping of `release` to a list of overlays, taken by recursively reading the filesystem to allow categorising overlays
{ inputs, host, lib }:
let
  inherit (builtins) readDir;
  inherit (lib.attrsets) collect filterAttrs mapAttrs;

  recurseRelease = directory:
    mapAttrs
      (name: type: {
        regular = import ./${directory}/${name} { inherit inputs host; };
        directory = recurseRelease "${directory}/${name}";
      }.${type} or null)
      (readDir ./${directory});
  collectOverlays = release:
    collect
      builtins.isFunction
      (recurseRelease release);
in
filterAttrs
  (_: overlays: overlays != [ ])
  (mapAttrs
    (name: _: collectOverlays name)
    (filterAttrs
      (_: type: type == "directory")
      (readDir ./.)))
