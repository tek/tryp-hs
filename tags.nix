{
  packages,
  pkgs,
  ghc,
  compiler,
  packageDir ? null,
  niv,
}:
let
  tagsSrc = niv.thax;
  # tagsSrc = ../thax;
  tags = import tagsSrc {
    inherit pkgs compiler;
  };
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
