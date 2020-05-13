{
  packages,
  ghc,
  packageDir ? null,
}:
let
  pkgs = import <nixpkgs> {};
  tags = import (fetchTarball "https://github.com/tek/thax/tarball/649e6bfe5ad9e5a8dc03857748f77027dae5fbac") {};
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
