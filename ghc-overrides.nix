{
  packages ? {},
  overrides ? _: _: {},
  cabal2nixOptions ? "",
}:
let
  nixpkgs = import <nixpkgs> {};
  local = ghc: n: s: nixpkgs.haskell.lib.dontCheck (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
  localOverrides = self: super:
    builtins.mapAttrs (local self) packages;
in
  nixpkgs.lib.composeExtensions localOverrides overrides
