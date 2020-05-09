{
  packages,
  ghc,
  packageDir ? null,
}:
let
  pkgs = import <nixpkgs> {};
  tags = import (fetchTarball "https://github.com/tek/thax/tarball/ac5fedc60f935a4b28545b974e7997bb98ae23ea") {};
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
