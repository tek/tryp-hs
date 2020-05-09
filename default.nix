rec {
  hackage = import ./hackage.nix;
  ghcNixpkgs = import ./ghc-nixpkgs.nix;
  ghcOverrides = import ./ghc-overrides.nix;
  ghci = import ./ghci.nix;
  ghcid = import ./ghcid.nix;
  packageSets = import ./package-sets.nix;
  tags = import ./tags.nix;

  project = {
    nixpkgs ? import <nixpkgs>,
    compiler ? "ghc865",
    ghciArgs ? [],
    overrides ? _: _: {},
    cabal2nixOptions ? "",
    base,
    packages,
  }:
  let
    pkgs = ghcNixpkgs { inherit nixpkgs compiler packages overrides cabal2nixOptions; };
    sets = packageSets { maps = { all = packages; }; };
    ghc = pkgs.haskell.packages.${compiler};
    ghci' = ghci { basicArgs = ghciArgs; };
  in {
    inherit pkgs sets ghc compiler;
    ghci = ghci';
    ghcid = ghcid { inherit ghc; packages = sets.all; ghci = ghci'; };
  };
}
