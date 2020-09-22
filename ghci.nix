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

  preproc_options_ghc =
    if (builtins.isNull options_ghc || options_ghc == "") then [] else ["-optF" options_ghc];

  preludeScript = prelude:
    ''
      :load ${toString prelude}
      import Prelude
      :set -XImplicitPrelude
    '';

  cwdScript = cwd:
  optionalString (cwd != null) ''
    :cd ${cwd}
  '';

in rec {
  args = {
    basic = prelude:
    ["-no-user-package-db" "-package-env" "-"] ++ basicArgs ++ optional (prelude != null) "-XNoImplicitPrelude";

    command =
      commandArgs;

    preprocessor =
      ["-F" "-pgmF" ./preprocessor.bash] ++ preproc_options_ghc;
  };

  scripts = rec {

    property = module: ''
      :load ${module}
      import ${module}
      import Hedgehog (check)
    '';

    unit = pkg: module: {
      cwd = testCwd pkg;
      script = ''
        :load ${module}
        import ${module}
        import Hedgehog (check, property, test, withTests)
      '';
    };

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
      cwd = if builtins.isAttrs script && script ? cwd then script.cwd else null;
      scriptText = if builtins.isAttrs script then script.script else script;
      basic = toString (args.basic prelude);
      command = toString args.command;
      preproc = toString args.preprocessor;
      search = searchPaths ((map libDir packages.dirs) ++ extraSearch);
      fullScript = cwdScript cwd + optionalString (prelude != null) (preludeScript prelude) + scriptText;
      scriptFile = pkgs.writeText "ghci-script" fullScript;
    in
    "ghci ${basic} ${command} ${preproc} ${search} -ghci-script ${scriptFile}";
}
