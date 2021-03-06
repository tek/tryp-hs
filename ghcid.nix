{
  base,
  niv,
  pkgs,
  packages,
  ghci,
  ghc,
  hls ? true,
  system-hls ? false,
  commands ? {},
  extraShellInputs ? [],
  extraShellPackages ? (_: []),
  prelude ? null,
}:
let
  version = ghc.ghc.version;
  lib = pkgs.lib;
  inherit (pkgs.haskell.lib) enableCabalFlag;
  inherit (lib.lists) any concatMap;
  hlsData = if hls then
  if version == "8.10.1" || version == "8.10.2"
  then import ./hls-ghc810.nix { inherit base pkgs ghc niv; }
  else import ./hls.nix { inherit base pkgs ghc niv; }
  else null;
  haskell-language-server = if hls then hlsData.hls else null;

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

  ghcidCmdFile = {
    packages,
    command,
    test,
    extraRestarts,
    preStartCommand,
    exitCommand,
  }:
  pkgs.writeScript "ghcid-cmd" ''
    ${preStartCommand}
    ${ghcidCmd packages command test extraRestarts}
    ${exitCommand}
  '';

  shellFor = {
    packages,
    hook ? "",
    env ? {},
    flags ? [],
    ide ? false,
  }:
  let
    isNotTarget = p: !(p ? pname && any (n: p.pname == n) packages);
    inputs = p: p.buildInputs ++ p.propagatedBuildInputs;
    hsPkgs = g: builtins.filter isNotTarget (concatMap inputs (map (p: g.${p}) packages)) ++ extraShellPackages g;
    ideInputs = if ide then [haskell-language-server] else [];
    args = {
      name = "ghci-shell";
      buildInputs = [ghc.ghcid ghc.cabal-install] ++ ideInputs ++ [(ghc.ghcWithPackages hsPkgs)] ++ extraShellInputs;
      shellHook = hook;
    };
  in
    pkgs.stdenv.mkDerivation (args // env);

  ghcidShellCmd = {
    packages,
    script,
    test,
    extraSearch ? [],
    extraRestarts ? [],
    preCommand ? "",
    preStartCommand ? "",
    exitCommand ? "",
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
  in ghcidCmdFile {
    packages = packages.byDir;
    inherit command test extraRestarts preStartCommand exitCommand;
  };

  ghciShellFor = name: {
    packages,
    script,
    test,
    extraSearch ? [],
    env ? {},
    extraRestarts ? [],
    preCommand ? "",
    preStartCommand ? "",
    exitCommand ? "",
    flags ? [],
    prelude ? null,
  }:
  shellFor {
    packages = packages.names;
    hook = ghcidShellCmd {
      inherit packages script test extraSearch extraRestarts preCommand preStartCommand exitCommand prelude;
    };
    inherit env flags;
  };

  shells = builtins.mapAttrs ghciShellFor commands;

  shellWith = args: shellFor ({ packages = packages.names; } // args);
in shells // {
  inherit commands shellFor shellWith ghcidCmdFile ghciShellFor haskell-language-server;
  hlsGhc = hlsData.ghc;
  hls = if system-hls then ghc.haskell-language-server else haskell-language-server;

  cmd = ghcidCmd;

  run =
    {
      pkg,
      module,
      name,
      type,
      runner,
      packages ? globalPackages,
      prelude ? null,
      env ? {},
      extraRestarts ? [],
      preCommand ? "",
      preStartCommand ? "",
      exitCommand ? "",
      flags ? [],
    }:
    ghciShellFor "run" {
      inherit packages env extraRestarts preCommand preStartCommand exitCommand flags prelude;
      script = ghci.scripts.run pkg module runner;
      test = ghci.tests.test name runner;
      extraSearch = [(testMod pkg type)];
    };

  shell = shellWith { ide = true; };
}
