{
  base,
}:
let
  niv = import ./nix/sources.nix;
  util = rec {
    hackage = import ./hackage.nix base;
    ghcNixpkgs = import ./ghc-nixpkgs.nix hackage;
    ghcOverrides = import ./ghc-overrides.nix hackage;
    ghci = import ./ghci.nix;
    ghcid = import ./ghcid.nix;
    packageSets = import ./package-sets.nix;
    tags = import ./tags.nix;
    cabal = import ./cabal.nix;
    hpack = import ./hpack.nix;
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

  dev = basic: args@{
    packageDir ? null,
    ...
  }:
  let
    ghciDefaults = {
      inherit base;
      inherit (basic) pkgs;
    };
    ghci = util.ghci (ghciDefaults // args.ghci or {});
    ghcidDefaults = {
      inherit ghci base niv;
      inherit (basic) pkgs ghc;
      packages = basic.sets.all;
    };
    ghcid = util.ghcid (ghcidDefaults // args.ghcid or {});
  in
    basic // {
      inherit ghci ghcid;
      tags = util.tags { packages = basic.sets.all; inherit packageDir; inherit (basic) compiler pkgs ghc; };
      cabal = util.cabal { packages = basic.sets.all.byPath; inherit ghcid; };
      hpack = util.hpack { inherit base; inherit (basic) pkgs; };
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
