rec {
  hackage = import ./hackage.nix;
  ghcNixpkgs = import ./ghc-nixpkgs.nix;
  ghcOverrides = import ./ghc-overrides.nix;
  ghci = import ./ghci.nix;
  ghcid = import ./ghcid.nix;
  packageSets = import ./package-sets.nix;
  tags = import ./tags.nix;

  projectWithSets = {
    nixpkgs ? import <nixpkgs>,
    compiler ? "ghc865",
    ghciArgs ? [],
    overrides ? _: _: {},
    cabal2nixOptions ? "",
    options_ghc ? null,
    base,
    sets,
    ...
  }:
  let
    packages = sets.all.byPath;
    pkgs = ghcNixpkgs { inherit nixpkgs compiler packages overrides cabal2nixOptions; };
    ghc = pkgs.haskell.packages.${compiler};
    ghci' = ghci { basicArgs = ghciArgs; inherit options_ghc base; };
  in {
    inherit pkgs sets ghc compiler;
    ghci = ghci';
    ghcid = ghcid { inherit ghc base; packages = sets.all; ghci = ghci'; };
  };

  project = args@{ packages, ... }:
  let
    sets = packageSets { maps = { all = packages; }; };
  in
    projectWithSets (args // { inherit sets; });
}
