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
      (jpack "HsYAML" "0.2.1.0" "0r2034sw633npz7d2i4brljb5q1aham7kjz6r6vfxx8qqb23dwnc")
      (jpack "HsYAML-aeson" "0.2.0.0" "0zgcp93y93h7rsg9dv202hf3l6sqr95iadd67lmfclb0npfs640m")
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      (pack "ansi-terminal" "0.10.3" "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k")
      (pack "apply-refact" "0.8.2.1" "0nnprv5lbk7c8w1pa4kywk0cny6prjaml4vnw70s8v6c1r1dx2rx")
      (pack "butcher" "1.3.3.2" "08lj4yy6951rjg3kr8613mrdk6pcwaidcx8pg9dvl4vpaswlpjib")
      (pack "extra" "1.7.7" "0jgcd8gw6d22ngbi0lp3ak2ghzza59nb3vssrjldwxiim0nzf71v")
      (pack "first-class-families" "0.8.0.0" "0266lqagnxmd80n9i0f1xsh4zfrmab5aazyp4ii5nqch3474gpm6")
      (jpack "floskell" "0.10.2" "02ippycd9vg36n9vmmczh9krr2dgxs6rp1jq3f60f040hwb45mp1")
      (pack "fourmolu" "0.2.0.0" "1dkv9n9m0wrpila8z3fq06p56c7af6avd9kv001s199b0ca7pwa6")
      (pack "ghc-check" "0.5.0.1" "1zlbss7h6infzhhpilvkpk50gxypkb2li8fspi69jlll5l7wqi3d")
      (pack "ghc-exactprint" "0.6.3.3" "0vcvfkkqqphgn9r5si6n80vhs27in1vmsz0siaywba7aapqqk81a")
      (pack "ghc-lib" "8.10.2.20200916" "1gx0ijay9chachmd1fbb61md3zlvj24kk63fk3dssx8r9c2yp493")
      (pack "ghc-lib-parser" "8.10.2.20200916" "1apm9zn484sm6b8flbh6a2kqnv1wjan4l58b81cic5fc1jsqnyjk")
      (pack "ghc-lib-parser-ex" "8.10.0.16" "0dp8plj708ss3im6rmp41kpj0df71kjzpw1kqkpn0dhms9yr1g0x")
      (pack "haddock-library" "1.9.0" "12nr4qzas6fzn5p4ka27m5gs2rym0bgbfrym34yp0cd6rw9zdcl3")
      (pack "haskell-lsp" "0.22.0.0" "1q3w46qcvzraxgmw75s7bl0qvb2fvff242r5vfx95sqska566b4m")
      (pack "haskell-lsp-types" "0.22.0.0" "1apjclphi2v6ggrdnbc0azxbb1gkfj3x1vkwpc8qd6lsrbyaf0n8")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "hlint" "3.2.1" "01ycw48n7sdx1jfp37vy684jp5y380ry703bngldlw22k4mdk7xq")
      (pack "hslogger" "1.3.1.0" "05ca3n1xx3mjg7lfal6mrqx3qsh1a64h2wfwclxvilxjg9h7jbmc")
      (pack "implicit-hie" "0.1.1.0" "1pnsc76zyzjj3zxxgl3jv6j23jdn1p35a7sw5i2l9202jj0v90pv")
      (pack "implicit-hie-cradle" "0.2.0.1" "0wka62csnc4pqy0fj5b9h2vgzg24isfv8g6zaazrkyjql1gxmbay")
      (pack "lsp-test" "0.11.0.6" "19mbbkjpgpmkna26i4y1jvp305srv3kwa5b62x30rlb3rqf2vy5v")
      (pack "monad-dijkstra" "0.1.1.3" "0b8yj2p6f0h210hmp9pnk42jzrrhc4apa0d5a6hpa31g66jxigy8")
      (pack "network" "2.8.0.1" "0nrgwcklb7a32wxmvbgxmm4zsbk3gpc6f2d8jpyb0b1hwy0ji4mv")
      (pack "network-bsd" "2.8.0.0" "1qcqz09z8155mbdmfc7hwqc8fph411czm4mlih8i608rhnlplkvb")
      (pack "optparse-applicative" "0.15.1.0" "1mii408cscjvids2xqdcy2p18dvanb0qc0q1bi7234r23wz60ajk")
      (pack "ormolu" "0.1.3.0" "0wmkqyavmhpxmrc794jda9x0gy6kmzlmv5waq1031xfgqxmki72y")
      (pack "parser-combinators" "1.2.1" "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h")
      (pack "primitive" "0.7.1.0" "1mmhfp95wqg6i5gzap4b4g87zgbj46nnpir56hqah97igsbvis7j")
      (pack "refinery" "0.3.0.0" "08s5pw6j3ncz96zfc2j0cna2zbf4vy7045d6jpzmq2sa161qnpgi")
      (pack "regex-base" "0.94.0.0" "0x2ip8kn3sv599r7yc9dmdx7hgh5x632m45ga99ib5rnbn6kvn8x")
      (pack "regex-tdfa" "1.3.1.0" "1a0l7kdjzp98smfp969mgkwrz60ph24xy0kh2dajnymnr8vd7b8g")
      (pack "retrie" "0.1.1.1" "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l")
      (pack "shake" "0.19.1" "14myzmdywbcwgx03f454ymf5zjirs7wj1bcnhhsf0w1ck122y8q3")
      (pack "stylish-haskell" "0.12.2.0" "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr")
      (pack "these" "1.1.1.1" "1i1nfh41vflvqxi8w8n2s35ymx2z9119dg5zmd2r23ya7vwvaka1")
    ];
  in builtins.listToAttrs versions // {
    brittany = cabal2nix "brittany" niv.brittany;
    ghcide = cabal2nix "ghcide" niv.ghcide;
    haskell-language-server = notest (cabal2nix "haskell-language-server" niv.hls);
    hie-compat = notest (subPkg "hie-compat" "hie-compat" niv.ghcide);
    hls-hlint-plugin = notest (subPkg "plugins/hls-hlint-plugin" "hls-hlint-plugin" niv.hls);
    hls-plugin-api = notest (subPkg "hls-plugin-api" "hls-plugin-api" niv.hls);
    hls-tactics-plugin = notest (subPkg "plugins/tactics" "hls-tactics-plugin" niv.hls);
  };
  finalGhc = ghc.override { overrides = pkgs.lib.composeExtensions (tools.derivationOverride false) deps; };
in {
  ghc = finalGhc;
  hls = pkgs.haskell.lib.justStaticExecutables finalGhc.haskell-language-server;
}
