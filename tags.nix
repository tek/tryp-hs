{
  packages,
  ghc,
  packageDir ? null,
}:
let
  pkgs = import <nixpkgs> {};
  tags = import (fetchTarball "https://github.com/tek/thax/tarball/3db97ebf3f60f209a10b12885e5cc4ec9b0c96de") {};
  withPrefix =
    name: dir:
    let
      p = ghc.${name};
    in
      if builtins.isNull packageDir
      then p
      else p // { tagsPrefix = "${packageDir}/${dir}"; };
  targets =
    pkgs.lib.attrsets.mapAttrsToList withPrefix packages.byDir;
in {
  projectTags =
    tags.combined.all { inherit targets; };
}
