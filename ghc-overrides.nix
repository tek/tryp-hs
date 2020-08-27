hackage:
{
  pkgs,
  overrides ? { ... }: _: _: {},
  packages ? {},
  cabal2nixOptions ? "",
  profiling ? false,
}:
let
  tools = import ./ghc-tools.nix { inherit packages; };
  inherit (pkgs.haskell.lib) dontCheck dontHaddock dontBenchmark;
  compose = pkgs.lib.composeExtensions;
  reduceWork = d: dontHaddock (dontBenchmark d);
  local = ghc: n: s: reduceWork (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
  localOverrides = self: super:
    builtins.mapAttrs (local self) packages;
  userOverrides = self: super:
    overrides { inherit pkgs; hackage = hackage { inherit pkgs self super; }; } self super;
in
  compose (tools.derivationOverride profiling) (compose localOverrides userOverrides)
