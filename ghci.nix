{
  base,
  basicArgs ? [],
  options_ghc ? null,

}:
let
  pkgs = import <nixpkgs> {};

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

in rec {
  args = {
    basic =
      ["-no-user-package-db" "-package-env" "-"] ++ basicArgs;

    preprocessor =
      ["-F" "-pgmF" ./preprocessor.bash] ++ preproc_options_ghc;
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

  command =
    packages: script: extraSearch:
    let
      basic = toString args.basic;
      preproc = toString args.preprocessor;
      search = searchPaths ((map libDir packages.dirs) ++ extraSearch);
      scriptFile = pkgs.writeText "ghci-script" script;
    in
    "ghci ${basic} ${preproc} ${search} -ghci-script ${scriptFile}";

  ghcide-conf =
    packages:
    ["-Werror"] ++ args.basic ++ args.preprocessor ++ [(searchPaths (map libDir packages.dirs))];
}
