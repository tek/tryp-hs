{
  base,
  niv,
  pkgs,
  packages,
  ghci,
  ghc,
  hls ? true,
  ghcide ? import ./ghcide.nix { inherit base pkgs ghc niv; },
  commands ? {},
  extraShellInputs ? [],
  extraShellPackages ? (_: []),
  prelude ? null,
}:
let
  lib = pkgs.lib;
  inherit (pkgs.haskell.lib) enableCabalFlag;
  inherit (lib.lists) any concatMap;
  haskell-language-server = if hls then import ./hls.nix { inherit base pkgs ghc niv; } else null;

  globalPackages = packages;
  globalPrelude = prelude;

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
    isNotTarget = p: !(p ? pname && any (n: p.pname == n) packages);
    inputs = p: p.buildInputs ++ p.propagatedBuildInputs;
    hsPkgs = g: builtins.filter isNotTarget (concatMap inputs (map (p: g.${p}) packages)) ++ extraShellPackages g;
    args = {
      name = "ghci-shell";
      buildInputs = [ghc.ghcid ghcide haskell-language-server ghc.cabal-install] ++ [(ghc.ghcWithPackages hsPkgs)] ++ extraShellInputs;
      shellHook = hook;
    };
  in
    pkgs.stdenv.mkDerivation (args // env);

  ghciShellFor = name: {
    packages,
    script,
    test,
    extraSearch ? [],
    env ? {},
    extraRestarts ? [],
    preCommand ? "",
    flags ? [],
    prelude ? null,
  }:
  let
    mainCommand = ghci.command {
      inherit packages script extraSearch;
      prelude = if isNull prelude then globalPrelude else prelude;
    };
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

  shellWith = args: shellFor ({ packages = packages.names; } // args);
in shells // {
  inherit commands shellFor shellWith ghcidCmdFile ghciShellFor ghcide haskell-language-server;
  hls = haskell-language-server;

  cmd = ghcidCmd;

  run =
    { pkg,
      module,
      name,
      type,
      runner,
      packages ? globalPackages,
      prelude ? null,
      env ? {},
      extraRestarts ? [],
      preCommand ? "",
      flags ? [],
    }:
    ghciShellFor "run" {
      inherit packages env extraRestarts preCommand flags prelude;
      script = ghci.scripts.run pkg module runner;
      test = ghci.tests.test name runner;
      extraSearch = [(testMod pkg type)];
    };

  shell = shellWith {};

  ghcide-conf =
    builtins.concatStringsSep "\n" (ghci.ghcide-conf packages);
}
