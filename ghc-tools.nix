rec {
  wantReduce = { pname, ... }:
    pname != "ghc";
  reduceDerivation = profiling: args: args // {
    doBenchmark = false;
    doCheck = false;
    doHoogle = false;
    doHaddock = false;
    enableLibraryProfiling = profiling;
  };
  derivationOverride = profiling: _: super: {
    mkDerivation = args:
    let
      finalArgs = if wantReduce args then reduceDerivation profiling args else args;
    in
      super.mkDerivation finalArgs;
  };
}
