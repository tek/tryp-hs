{
  packages,
  pkgs,
  ghc,
  compiler,
  packageDir ? null,
}:
let
  tagsSrc = fetchTarball "https://github.com/tek/thax/tarball/95e0c9693bca1ea4ff197950dd0df1d8536e68ab";
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
