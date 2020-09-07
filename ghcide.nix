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
    inherit (hack) hackage pack notest curated cabal2nix versionOverrides;
    versions = [
      (pack "ghc-check" "0.5.0.1" "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d")
      (pack "extra" "1.7.7" "0jgcd8gw6d22ngbi0lp3ak2ghzza59nb3vssrjldwxiim0nzf71v")
      (pack "lsp-test" "0.11.0.4" "17lab7rfxsfnzqvb2fvgvj2wcygn11hybal7kazykvgnnxfm7fch")
      (pack "parser-combinators" "1.2.1" "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h")
      (pack "haddock-library" "1.9.0" "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3")
      (pack "haskell-lsp" "0.22.0.0" "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m")
      (pack "haskell-lsp-types" "0.22.0.0" "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
    ];
  in builtins.listToAttrs versions // {
    regex-posix = curated "regex-posix" "0.96.0.0";
    test-framework = curated "test-framework" "0.8.2.0";
    regex-base = curated "regex-base" "0.94.0.0";
    regex-tdfa = curated "regex-tdfa" "1.3.1.0";
    shake = curated "shake" "0.18.4";
    ghcide = notest (cabal2nix "ghcide" niv.ghcide);
  };
  finalGhc = ghc.override { overrides = pkgs.lib.composeExtensions (tools.derivationOverride false) deps; };
in
  pkgs.haskell.lib.justStaticExecutables finalGhc.ghcide
