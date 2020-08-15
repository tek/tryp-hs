{
  base,
}:
let
  util = rec {
    hackage = import ./hackage.nix base;
    ghcNixpkgs = import ./ghc-nixpkgs.nix hackage;
    ghcOverrides = import ./ghc-overrides.nix hackage;
    ghci = import ./ghci.nix;
    ghcid = import ./ghcid.nix;
    packageSets = import ./package-sets.nix;
    tags = import ./tags.nix;
  };

  basic = {
    nixpkgs ? import <nixpkgs>,
    compiler ? "ghc865",
    overrides ? { ... }: _: _: {},
    cabal2nixOptions ? "",
    profiling ? false,
    base,
    sets,
    ...
  }: rec {
    inherit compiler sets;
    pkgs = util.ghcNixpkgs {
      inherit nixpkgs compiler overrides cabal2nixOptions profiling;
      packages = sets.all.byPath;
    };
    ghc = pkgs.haskell.packages.${compiler};
  };

  dev = basic: {
    ghciArgs ? [],
    ghciCommandArgs ? [],
    commands ? {},
    options_ghc ? null,
    ...
  }: basic // rec {
    ghci = util.ghci { basicArgs = ghciArgs; commandArgs = ghciCommandArgs; inherit options_ghc base; };
    ghcid = util.ghcid { inherit ghci base commands; inherit (basic) ghc; packages = basic.sets.all; };
  };

  projectWithSets = args: dev (basic args) args;
in {
  inherit util basic dev projectWithSets;

  project = args@{ packages, ... }:
  let
    sets = util.packageSets { maps = { all = packages; }; };
  in
    projectWithSets (args // { inherit sets; });
}
