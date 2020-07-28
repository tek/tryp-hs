{
  base,
  commands ? {},
  packages,
  ghci,
  ghc,
  ghcide ? import ./ghcide.nix { inherit ghc; },
}:
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  restart =
    f: "--restart='${f}'";

  pkgRestarts =
    lib.attrsets.mapAttrsToList (n: d: restart "packages/${d}/${n}.cabal");

  testMod =
    pkg: type: "${toString base}/packages/${pkg}/${type}";

  ghciCmdFile =
    pkgs.writeScript "ghci-cmd";

  ghcidCmd =
    packages: command: test: extraRestarts:
    let
      restarts = (pkgRestarts packages) ++ (map restart extraRestarts);
    in
      "ghcid -W ${toString restarts} --command='${command}' --test='${test}'";

  ghcidCmdFile =
    packages: command: test: extraRestarts:
    pkgs.writeScript "ghcid-cmd" (ghcidCmd packages command test extraRestarts);

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
    extraRestarts ? [],
    preCommand ? "",
  }:
  let
    mainCommand = ghci.command packages script extraSearch;
    command = ''
      ${preCommand}
      ${mainCommand}
    '';
  in shellFor {
    packages = packages.names;
    hook = ghcidCmdFile packages.byDir command test extraRestarts;
    inherit env;
  };

  shells = builtins.mapAttrs ghciShellFor commands;

  globalPackages = packages;
in shells // {
  inherit commands shellFor ghcidCmdFile;

  cmd = ghcidCmd;
  cmdFile = ghcidCmdFile ghciShellFor;

  run =
    { pkg,
      module,
      name,
      type,
      runner,
      packages ? globalPackages,
      env ? {},
      extraRestarts ? [],
      preCommand ? "",
    }:
    ghciShellFor "run" {
      inherit packages env extraRestarts preCommand;
      script = ghci.scripts.run pkg module runner;
      test = ghci.tests.test name runner;
      extraSearch = [(testMod pkg type)];
    };

  shell = shellFor { packages = packages.names; };

  ghcide-conf =
    builtins.concatStringsSep "\n" (ghci.ghcide-conf packages);
}
