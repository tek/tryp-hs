{
  compiler,
  overrides ? { ... }: _: _: {},
  packages ? {},
  cabal2nixOptions ? "",
  profiling ? false,
}:
self: super:
let
  hackage = import ./hackage.nix;
  combined = import ./ghc-overrides.nix {
    inherit overrides packages cabal2nixOptions profiling;
    pkgs = self;
  };
in {
  haskell = super.haskell // {
    packages = super.haskell.packages // {
      ${compiler} = super.haskell.packages.${compiler}.override { overrides = combined; };
    };
  };
}
