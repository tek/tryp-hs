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
      (jpack "HsYAML-aeson" "0.2.0.0" "0zgcp93y93h7rsg9dv202hf3l6sqr95iadd67lmfclb0npfs640m")
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      (pack "ansi-terminal" "0.10.3" "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k")
      (pack "butcher" "1.3.3.2" "08lj4yy6951rjg3kr8613mrdk6pcwaidcx8pg9dvl4vpaswlpjib")
      (pack "extra" "1.7.7" "0jgcd8gw6d22ngbi0lp3ak2ghzza59nb3vssrjldwxiim0nzf71v")
      (pack "first-class-families" "0.8.0.0" "0266lqagnxmd80n9i0f1xsh4zfrmab5aazyp4ii5nqch3474gpm6")
      (jpack "floskell" "0.10.2" "02ippycd9vg36n9vmmczh9krr2dgxs6rp1jq3f60f040hwb45mp1")
      (pack "fourmolu" "0.1.0.0" "0kwcgd66vyihqiqip2ilq4p1l16v2kskhv2d4p6d33s9qn85mfw0")
      (pack "ghc-check" "0.5.0.1" "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d")
      (pack "ghc-exactprint" "0.6.2" "1mmfing76jyh5qwnk05d6lj7k4flchc3z7aqzrp8m4z684rxvqkn")
      (pack "ghc-lib-parser" "8.10.2.20200916" "1apm9zn484sm6b8flbh6a2kqnv1wjan4l58b81cic5fc1jsqnyjk")
      (pack "haddock-library" "1.9.0" "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3")
      (pack "haskell-lsp" "0.22.0.0" "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m")
      (pack "haskell-lsp-types" "0.22.0.0" "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "hslogger" "1.3.1.0" "05ca3n1xx3mjg7lfal6mrqx3qsh1a64h2wfwclxvilxjg9h7jbmc")
      (pack "implicit-hie" "0.1.1.0" "1pnsc76zyzjj3zxxgl3jv6j23jdn1p35a7sw5i2l9202jj0v90pv")
      (pack "implicit-hie-cradle" "0.2.0.0" "1x553pp3lx1k4m28qrdl8ihj2gkiraaqw32y1zf7x2vm5mksh3bs")
      (pack "lsp-test" "0.11.0.6" "19mbbkjpgpmkna26i4y1jvp305srv3kwa5b62x30rlb3rqf2vy5v")
      (pack "monad-dijkstra" "0.1.1.3" "0b8yj2p6f0h210hmp9pnk42jzrrhc4apa0d5a6hpa31g66jxigy8")
      (pack "network" "2.8.0.1" "0nrgwcklb7a32wxmvbgxmm4zsbk3gpc6f2d8jpyb0b1hwy0ji4mv")
      (pack "ormolu" "0.1.3.0" "0wmkqyavmhpxmrc794jda9x0gy6kmzlmv5waq1031xfgqxmki72y")
      (pack "parser-combinators" "1.2.1" "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h")
      (pack "primitive" "0.7.1.0" "1mmhfp95wqg6i5gzap4b4g87zgbj46nnpir56hqah97igsbvis7j")
      (pack "retrie" "0.1.1.1" "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l")
      (pack "shake" "0.19.1" "14myzmdywbcwgx03f454ymf5zjirs7wj1bcnhhsf0w1ck122y8q3")
      (pack "stylish-haskell" "0.11.0.3" "0rnvcil7i9z7ra2b4znsychlxdj6zm4capdzih1n1v0jp9xi31ac")
      (pack "these" "1.1.1.1" "1i1nfh41vflvqxi8w8n2s35ymx2z9119dg5zmd2r23ya7vwvaka1")
    ];
  in builtins.listToAttrs versions // {
    ghcide = cabal2nix "ghcide" niv.ghcide-hls;
    brittany = cabal2nix "brittany" niv.brittany;
    hls-plugin-api = notest (subPkg "hls-plugin-api" "hls-plugin-api" niv.haskell-language-server);
    haskell-language-server = notest (cabal2nix "haskell-language-server" niv.haskell-language-server);
  };
  finalGhc = ghc.override { overrides = pkgs.lib.composeExtensions (tools.derivationOverride false) deps; };
in
  pkgs.haskell.lib.justStaticExecutables finalGhc.haskell-language-server
