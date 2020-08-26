{
  base,
  commands ? {},
  pkgs,
  packages,
  ghci,
  ghc,
  ghcide ? import ./ghcide.nix { inherit base pkgs ghc; },
}:
let
  lib = pkgs.lib;
  inherit (pkgs.haskell.lib) enableCabalFlag;

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
    flags ? [],
  }:
  let
    withFlags = pkg:
    builtins.foldl' enableCabalFlag pkg flags;
    args = {
      packages = p: map (n: withFlags p.${n}) packages;
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
    flags ? [],
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
    inherit env flags;
  };

  shells = builtins.mapAttrs ghciShellFor commands;

  globalPackages = packages;
in shells // {
  inherit commands shellFor ghcidCmdFile ghcide;

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
      flags ? [],
    }:
    ghciShellFor "run" {
      inherit packages env extraRestarts preCommand flags;
      script = ghci.scripts.run pkg module runner;
      test = ghci.tests.test name runner;
      extraSearch = [(testMod pkg type)];
    };

  shell = shellFor { packages = packages.names; };

  ghcide-conf =
    builtins.concatStringsSep "\n" (ghci.ghcide-conf packages);
}
