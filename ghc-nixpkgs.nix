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
    compose = self.lib.composeExtensions;
    local = ghc: n: s: self.haskell.lib.dontCheck (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
    localOverrides = ghcSelf: ghcSuper:
      builtins.mapAttrs (local ghcSelf) packages;
    profilingOverride = _: super: {
      mkDerivation = expr: super.mkDerivation (expr // {
        enableLibraryProfiling = profiling;
      });
    };
    userOverrides = ghcSelf: ghcSuper:
      overrides { pkgs = self; hackage = hackage { pkgs = self; self = ghcSelf; super = ghcSuper; }; } ghcSelf ghcSuper;
    combined = compose profilingOverride (compose localOverrides userOverrides);
  in {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        ${compiler} = super.haskell.packages.${compiler}.override { overrides = combined; };
      };
    };
  };
in
  nixpkgs { overlays = [overlay]; }
