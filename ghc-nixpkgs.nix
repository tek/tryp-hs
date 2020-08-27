hackage:
{
  nixpkgs,
  compiler,
  overrides ? { ... }: _: _: {},
  packages ? {},
  cabal2nixOptions ? "",
  profiling ? false,
}:
let
  overlay = self: super:
  let
    combined = import ./ghc-overrides.nix hackage {
      inherit overrides packages cabal2nixOptions profiling;
      pkgs = self;
    };
  in {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        ${compiler} = super.haskell.packages.${compiler}.override { overrides = combined; };
      };
    };
  };
in
  nixpkgs { overlays = [overlay]; }
