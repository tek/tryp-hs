{
  ghc,
}:
let
  pkgs = import <nixpkgs> {};
  ghcideSrc =
    pkgs.fetchFromGitHub {
      owner = "digital-asset";
      repo = "ghcide";
      rev = "cbafcf29f4157e86e0522d87bf99cb2aeff1d853";
      sha256 = "1hn8d65wxp4fnh2pnwl2br5dr7xkkn1rykhc030d5qjak8l70j4c";
    };
  # ghcideSrc = ../../../ext/haskell/ghcide;
  deps = self: super:
  let
    hack = import ./hackage.nix { inherit pkgs self super; };
    inherit (hack) hackage pack notest curated cabal2nix;
  in {
    ghc-check = hackage {
      pkg = "ghc-check";
      ver = "0.5.0.1";
      sha256 = "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d";
    };
    lsp-test = hackage {
      pkg = "lsp-test";
      ver = "0.11.0.2";
      sha256 = "1jwvalwj3jblw32zig7d7d3251c6a3k3c2npvkypaslk3w2r8cq8";
    };
    parser-combinators = hackage {
      pkg = "parser-combinators";
      ver = "1.2.1";
      sha256 = "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h";
    };
    haddock-library = curated "haddock-library" "1.8.0";
    haskell-lsp = hackage {
      pkg = "haskell-lsp";
      ver = "0.22.0.0";
      sha256 = "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m";
    };
    haskell-lsp-types = hackage {
      pkg = "haskell-lsp-types";
      ver = "0.22.0.0";
      sha256 = "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8";
    };
    regex-posix = curated "regex-posix" "0.96.0.0";
    test-framework = curated "test-framework" "0.8.2.0";
    regex-base = curated "regex-base" "0.94.0.0";
    regex-tdfa = curated "regex-tdfa" "1.3.1.0";
    shake = curated "shake" "0.18.4";
    hie-bios = hackage {
      pkg = "hie-bios";
      ver = "0.5.0";
      sha256 = "116nmpva5jmlgc2dgy8cm5wv6cinhzmga1l0432p305074w720r2";
    };
    extra = hackage {
      pkg = "extra";
      ver = "1.7.2";
      sha256 = "1sz6hnnas0ck01zkgcar7nl41nxa6s6vq6aa45534w76gy8dyqpv";
    };
    ghcide = notest (cabal2nix "ghcide" ghcideSrc);
  };
  finalGhc = ghc.override { overrides = deps; };
in
  pkgs.haskell.lib.justStaticExecutables finalGhc.ghcide
