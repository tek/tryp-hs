{
  base,
  commands ? {},
  packages,
  ghci,
  ghc,
}:
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  ghcide = import ./ghcide.nix { inherit ghc; };

  restarts =
    lib.attrsets.mapAttrsToList (n: d: "--restart='packages/${d}/${n}.cabal'");

  testMod =
    pkg: type: "${toString base}/packages/${pkg}/${type}";

  ghcidCmd =
    packages: command: test:
    "ghcid -W --reload=config ${toString (restarts packages)} --command='${command}' --test='${test}'";

  ghcidCmdFile =
    packages: command: test:
    pkgs.writeScript "ghcid-cmd" (ghcidCmd packages command test);

  shellFor = {
    packages,
    hook ? "",
    env ? {},
  }:
  let
    args = {
      packages = p: map (n: p.${n}) packages;
      buildInputs = [ghc.ghcid ghcide ghc.cabal-install];
      shellHook = hook;
    };
  in
    ghc.shellFor (args // env);

  ghciShellFor = name: {
    packages,
    script,
    test,
    extraSearch ? [],
    env ? {},
  }:
  let
    command = ghci.command packages script extraSearch;
  in shellFor {
    packages = packages.names;
    hook = ghcidCmdFile packages.byDir command test;
    inherit env;
  };

  shells = builtins.mapAttrs ghciShellFor commands;
in shells // {
  inherit commands shellFor;

  cmd = ghcidCmd;
  cmdFile = ghcidCmdFile;

  run =
    { pkg, module, name, type, runner }:
    ghciShellFor "run" {
      inherit packages;
      script = ghci.scripts.run pkg module runner;
      test = ghci.tests.test name runner;
      extraSearch = [(testMod pkg type)];
    };

  shell = shellFor { packages = packages.names; };

  ghcide-conf =
    builtins.concatStringsSep "\n" (ghci.ghcide-conf packages);
}
