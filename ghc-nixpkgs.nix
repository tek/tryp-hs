{
  nixpkgs,
  compiler,
  overrides ? _: _: {},
  packages ? {},
  cabal2nixOptions ? "",
}:
let
  overlay = self: super:
  let
    local = ghc: n: s: self.haskell.lib.dontCheck (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
    localOverrides = ghcSelf: ghcSuper:
      builtins.mapAttrs (local ghcSelf) packages;
    combined = self.lib.composeExtensions localOverrides overrides;
  in {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        ${compiler} = super.haskell.packages.${compiler}.override { overrides = combined; };
      };
    };
  };
in
  nixpkgs { overlays = [overlay]; }
