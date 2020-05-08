{
  maps,
}:
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs.lib.attrsets) mapAttrs attrValues attrNames;
  projects =
    _: byPath: rec {
      inherit byPath;
      byDir = mapAttrs (_: p: baseNameOf p) byPath;
      paths = attrValues byPath;
      dirs = attrValues byDir;
      names = attrNames byPath;
    };
in
  mapAttrs projects maps
