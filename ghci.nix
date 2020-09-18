{
  base,
  pkgs,
  basicArgs ? [],
  commandArgs ? [],
  options_ghc ? null,
}:
let
  inherit (pkgs.lib.lists) optional;
  inherit (pkgs.lib.strings) optionalString;

  testCwd =
    pkg: "${toString base}/packages/${pkg}";

  libDir = m: "${toString base}/packages/${m}/lib";

  colonSeparated =
    builtins.concatStringsSep ":";

  searchPaths =
    paths:
    "-i${colonSeparated paths}";

  preludeScript = prelude:
    ''
      :load ${toString prelude}
      import Prelude
      :set -XImplicitPrelude
    '';

in rec {
  args = {
    basic = prelude:
    ["-no-user-package-db" "-package-env" "-"] ++ basicArgs ++ optional (prelude != null) "-XNoImplicitPrelude";

    command =
      commandArgs;

  };

  scripts = rec {

    property = module: ''
      :load ${module}
      import ${module}
      import Hedgehog (check)
    '';

    unit = pkg: module: ''
      :cd ${testCwd pkg}
      :load ${module}
      import ${module}
      import Hedgehog (check, property, test, withTests)
    '';

    generic = module: ''
      :load ${module}
      import ${module}
    '';

    run = pkg: module: runner:
    if runner == "hedgehog-property"
    then property module
    else if runner == "hedgehog-unit"
    then unit pkg module
    else generic module;

  };

  tests = {
    test =
      name: runner:
      if runner == "hedgehog-property"
      then "check ${name}"
      else if runner == "hedgehog-unit"
      then "(check . withTests 1 . property . test) ${name}"
      else name;
  };

  command = {
    packages,
    script,
    extraSearch,
    prelude ? null,
  }:
    let
      basic = toString (args.basic prelude);
      command = toString args.command;
      search = searchPaths ((map libDir packages.dirs) ++ extraSearch);
      fullScript = optionalString (prelude != null) (preludeScript prelude) + script;
      scriptFile = pkgs.writeText "ghci-script" fullScript;
    in
    "ghci ${basic} ${command} ${search} -ghci-script ${scriptFile}";
}
