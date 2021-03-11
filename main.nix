inputs:
let
  util = rec {
    hackage = import ./hackage.nix;
    ghcNixpkgs = import ./ghc-nixpkgs.nix hackage;
    ghcOverrides = import ./ghc-overrides.nix hackage;
    ghci = import ./ghci.nix;
    ghcid = import ./ghcid.nix;
    packageSets = import ./package-sets.nix;
    tags = import ./tags.nix;
    cabal = import ./cabal.nix;
    hpack = import ./hpack.nix;
    obelisk = import ./obelisk inputs;
  };

  basic = {
    nixpkgs ? inputs.nixpkgs,
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
      inherit (basic) pkgs base;
    };
    ghci = util.ghci (ghciDefaults // args.ghci or {});
    ghcidDefaults = {
      niv = inputs;
      inherit ghci;
      inherit (basic) pkgs ghc base;
      packages = basic.sets.all;
    };
    ghcid = util.ghcid (ghcidDefaults // args.ghcid or {});
  in
    basic // {
      inherit ghci ghcid;
      tags = util.tags {
        packages = basic.sets.all;
        inherit packageDir;
        inherit (basic) compiler pkgs ghc;
        niv = inputs;
      };
      cabal = util.cabal { packages = basic.sets.all.byPath; inherit ghcid; };
      hpack = { verbose ? false }: util.hpack { inherit verbose; inherit (basic) pkgs base; };
    };

  projectWithSets = args: dev (basic args) args;

  project = args@{ packages, ... }:
    projectWithSets (args // { sets = util.packageSets { maps = { all = packages; }; }; });

  obelisk = util.obelisk;
in {
  inherit util basic dev projectWithSets project obelisk;
}

