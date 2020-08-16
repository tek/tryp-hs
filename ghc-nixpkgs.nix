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
    inherit (self.haskell.lib) dontCheck dontHaddock dontBenchmark;
    compose = self.lib.composeExtensions;
    reduceWork = d: dontHaddock (dontCheck (dontBenchmark d));
    local = ghc: n: s: reduceWork (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
    localOverrides = ghcSelf: ghcSuper:
      builtins.mapAttrs (local ghcSelf) packages;
    profilingOverride = _: ghcSuper: {
      mkDerivation = args: ghcSuper.mkDerivation (args // {
        doBenchmark = false;
        doCheck = false;
        doHoogle = false;
        doHaddock = false;
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
