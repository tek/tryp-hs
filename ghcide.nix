{
  ghc,
}:
let
  pkgs = import <nixpkgs> {};
  ghcideSrc =
    pkgs.fetchFromGitHub {
      owner = "digital-asset";
      repo = "ghcide";
      rev = "master";
      sha256 = "1rz8qikjjd9ij68r077864n68v36xcrqjgp0ji1imvz1ap91izbm";
    };
  deps = self: super:
  let
    hack = import ./hackage.nix { inherit pkgs self super; };
    inherit (hack) hackage pack notest curated cabal2nix;
  in {
    ghc-check = hackage {
      pkg = "ghc-check";
      ver = "0.3.0.1";
      sha256 = "1dj909m09m24315x51vxvcl28936ahsw4mavbc53danif3wy09ns";
    };
    lsp-test = curated "lsp-test" "0.6.1.0";
    haddock-library = curated "haddock-library" "1.8.0";
    haskell-lsp = hackage {
      pkg = "haskell-lsp";
      ver = "0.21.0.0";
      sha256 = "1j6nvaxppr3wly2cprv556yxr220qw1ghd3ac139iw16ihfjvz8a";
    };
    haskell-lsp-types = hackage {
      pkg = "haskell-lsp-types";
      ver = "0.21.0.0";
      sha256 = "0vq7v6k9szmwxh2haphgzb3c2xih6h5yyq57707ncg0ha75bhlll";
    };
    regex-posix = curated "regex-posix" "0.96.0.0";
    test-framework = curated "test-framework" "0.8.2.0";
    regex-base = curated "regex-base" "0.94.0.0";
    regex-tdfa = curated "regex-tdfa" "1.3.1.0";
    shake = curated "shake" "0.18.4";
    hie-bios = hackage {
      pkg = "hie-bios";
      ver = "0.4.0";
      sha256 = "19lpg9ymd9656cy17vna8wr1hvzfal94gpm2d3xpnw1d5qr37z7x";
    };
    ghcide = cabal2nix "ghcide" ghcideSrc;
  };
  finalGhc = ghc.override { overrides = deps; };
in
  pkgs.haskell.lib.justStaticExecutables finalGhc.ghcide
