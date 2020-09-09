{
  base,
  niv,
  pkgs,
  ghc,
}:
let
  tools = import ./ghc-tools.nix {};
  deps = self: super:
  let
    hack = import ./hackage.nix base { inherit pkgs self super; };
    inherit (hack) hackage pack jpack notest curated cabal2nix versionOverrides subPkg;
    versions = [
      (pack "ghc-check" "0.5.0.1" "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d")
      (pack "extra" "1.7.7" "0jgcd8gw6d22ngbi0lp3ak2ghzza59nb3vssrjldwxiim0nzf71v")
      (pack "lsp-test" "0.11.0.4" "17lab7rfxsfnzqvb2fvgvj2wcygn11hybal7kazykvgnnxfm7fch")
      (pack "parser-combinators" "1.2.1" "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h")
      (pack "haddock-library" "1.9.0" "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3")
      (pack "haskell-lsp" "0.22.0.0" "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m")
      (pack "haskell-lsp-types" "0.22.0.0" "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      # (pack "data-fix" "0.3.0" "1w3z4fa28zxqwgsynlz025rkmrdcv7bj66031l502nc3x3yfljn6")
      # (pack "strict" "0.4" "0sl9mfpnyras2jlpjfnji4406fzp0yg2kxfcr22s3zwpir622a97")
      # (jpack "stylish-haskell" "0.11.0.3" "0rnvcil7i9z7ra2b4znsychlxdj6zm4capdzih1n1v0jp9xi31ac")
    ];
  in builtins.listToAttrs versions // {
    regex-posix = curated "regex-posix" "0.96.0.0";
    test-framework = curated "test-framework" "0.8.2.0";
    regex-base = curated "regex-base" "0.94.0.0";
    regex-tdfa = curated "regex-tdfa" "1.3.1.0";
    shake = curated "shake" "0.18.4";
    fourmolu = curated "fourmolu" "0.1.0.0";
    retrie = curated "retrie" "0.1.1.1";
    ghcide = notest (cabal2nix "ghcide" niv.ghcide-hls);
    brittany = notest (cabal2nix "brittany" niv.brittany);
    hls-plugin-api = notest (subPkg "hls-plugin-api" "hls-plugin-api" niv.haskell-language-server);
    haskell-language-server = notest (cabal2nix "haskell-language-server" niv.haskell-language-server);
  };
  finalGhc = ghc.override { overrides = pkgs.lib.composeExtensions (tools.derivationOverride false) deps; };
in
  pkgs.haskell.lib.justStaticExecutables finalGhc.haskell-language-server
