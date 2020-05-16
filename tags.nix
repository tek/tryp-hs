{
  packages,
  ghc,
  packageDir ? null,
}:
let
  pkgs = import <nixpkgs> {};
  tags = import (fetchTarball "https://github.com/tek/thax/tarball/9ac46dfef0a99a74e65c838a89d0bbab00170d8b") {};
  # tags = import ../thax {};
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
