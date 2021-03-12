{
  base,
  niv,
  pkgs,
  ghc,
}:
let
  inherit (pkgs) lib;
  tools = import ./ghc-tools.nix {};
  deps = self: super:
  let
    hack = import ./hackage.nix { inherit pkgs self super; };
    inherit (hack) hackage pack jpack notest curated cabal2nix versionOverrides subPkg;
    versions = [
      (jpack "HsYAML" "0.2.1.0" "0r2034sw633npz7d2i4brljb5q1aham7kjz6r6vfxx8qqb23dwnc")
      (jpack "HsYAML-aeson" "0.2.0.0" "0zgcp93y93h7rsg9dv202hf3l6sqr95iadd67lmfclb0npfs640m")
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      (pack "ansi-terminal" "0.10.3" "1aa8lh7pl054kz7i59iym49s8w473nhdqgc3pq16cp5v4358hw5k")
      (pack "apply-refact" "0.9.0.0" "1vxxzfajg248lk4s6lh1jjkn1rym8x6zs5985i5kpz989k6cpyx5")
      (pack "brittany" "0.13.1.0" "172mg0ch2awfzhz8vzvjrfdjylfzawrbgfr5z82l1qzjh6g9z295")
      (jpack "data-tree-print" "0.1.0.2" "12k7m0xqzslzlj38v4072cscmhk1y9hdj6ck4c87dj5p2da6f8qz")
      (pack "Diff" "0.4.0" "1phz4cz7i53jx3d1bj0xnx8vpkk482g4ph044zv5c6ssirnzq3ng")
      (pack "extra" "1.7.9" "0q64x7qiw0zsi8dv958nrqidjlgv9w20wva1y73affq8470m28vh")
      (pack "floskell" "0.10.5" "1flhdky8df170i1f2n5q3d4f3swma47m9lqwmzr5cg4dgjk85vdr")
      (pack "fourmolu" "0.3.0.0" "05b8ksifahahha3ra1mjby1gr9ysm5jc8li09v40l36z8n370l28")
      (pack "ghc-check" "0.5.0.3" "1q9ayvnawx7jsfgcnd6z28vf40iiybwj9d8xkwy5m7ngsyv8115f")
      (pack "ghc-exactprint" "0.6.3.3" "0vcvfkkqqphgn9r5si6n80vhs27in1vmsz0siaywba7aapqqk81a")
      (pack "ghc-lib" "8.10.3.20201220" "1zn1jsl3xdfyiymq9yzhrzwkk8g77bhblbsgahf3w59fpinp43lj")
      (pack "ghc-lib-parser" "8.10.3.20201220" "0ah9wp2m49kpfj7zhi9gs00jwvqcv1n00xdb5l4m6vbmps6dwcsl")
      (pack "ghc-lib-parser-ex" "8.10.0.17" "1wh0886bdpnfn90h1lbfrpr36jlyy2x4m1mqlwmr01pl5h19xb5z")
      (pack "ghc-trace-events" "0.1.2.1" "10vrm7hmg97fn8xf0r79d9vfph0j2s105lsgm0hgqay1qz1x7sp7")
      (pack "hashable" "1.3.0.0" "10w1a9175zxy11awir48axanyy96llihk1dnfgypn9qwdnqd9xnx")
      (pack "haskell-lsp" "0.23.0.0" "0d9bk1cqkk41frm81j683h2vd1hghl4hlvj8g17690d2qk5pq3c0")
      (pack "haskell-lsp-types" "0.23.0.0" "17mfc2zxkbwipxiy0g3qwqnyp8ds4mrg0z1v7jchcm89hnf8mmmq")
      (pack "heapsize" "0.3.0.1" "0c8lqndpbx9ahjrqyfxjkj0z4yhm1zlcn8al0ir4ldlahql2xv3r")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "hlint" "3.2.7" "1w3f0140c347kjhk6sbjh28p4gf4f1nrzp4rn589j3dkcb672l43")
      (pack "implicit-hie-cradle" "0.3.0.2" "1fhc8zccd7g7ixka05cba3cd4qf5jvq1zif29bhn593dfkzy89lz")
      (pack "implicit-hie" "0.1.2.5" "1l0rz4r4hamvmqlb68a7y4s3n73y6xx76zyprksd0pscd9axznnv")
      (pack "lsp-test" "0.11.0.7" "160w3a5mmgjwfgmdrv2ahb4j5r9axc0y52limyrps8nb2s0xrqbf")
      (pack "monad-dijkstra" "0.1.1.3" "0b8yj2p6f0h210hmp9pnk42jzrrhc4apa0d5a6hpa31g66jxigy8")
      (pack "opentelemetry" "0.6.1" "08k71z7bns0i6r89nmxqsl00kyksicq619rqy6pf5m7hq1r4zs9m")
      (pack "optparse-applicative" "0.15.1.0" "1mii408cscjvids2xqdcy2p18dvanb0qc0q1bi7234r23wz60ajk")
      (pack "ormolu" "0.1.4.1" "07gfag591dsys33q2i80f3afxjqny2zpiq4z35d1ajyp7di73m7z")
      (pack "parser-combinators" "1.2.1" "1990d6c1zm2wq4w9521bx7l3arg4ly02hq1ass9n19gs273bxx5h")
      (pack "primitive" "0.7.1.0" "1mmhfp95wqg6i5gzap4b4g87zgbj46nnpir56hqah97igsbvis7j")
      (pack "refinery" "0.3.0.0" "08s5pw6j3ncz96zfc2j0cna2zbf4vy7045d6jpzmq2sa161qnpgi")
      (pack "regex-base" "0.94.0.0" "0x2ip8kn3sv599r7yc9dmdx7hgh5x632m45ga99ib5rnbn6kvn8x")
      (pack "regex-tdfa" "1.3.1.0" "1a0l7kdjzp98smfp969mgkwrz60ph24xy0kh2dajnymnr8vd7b8g")
      (pack "retrie" "0.1.1.1" "0gnp6j35jnk1gcglrymvvn13sawir0610vh0z8ya6599kyddmw7l")
      (pack "shake" "0.19.4" "0dr3jpa70mvq8kq9k27bm8jxch4pcm810xqgjg5pg29dg978x78c")
      (pack "stylish-haskell" "0.12.2.0" "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr")
      (pack "these" "1.1.1.1" "1i1nfh41vflvqxi8w8n2s35ymx2z9119dg5zmd2r23ya7vwvaka1")
      (pack "uniplate" "1.6.13" "01p79pxmgdq8ya8llwrip5awc521y6qdchqw18ydkkidglv5m3bj")
      (pack "with-utf8" "1.0.2.1" "1hpqc0ljk1c1vl4671zb290hbvdcjpg66bcxmf1cz8h0vb382xp7")
    ];
  plugin = n:
  let
    name = "hls-${n}-plugin";
  in
    { ${name} = notest (subPkg "plugins/hls-${n}-plugin" "hls-${n}-plugin" niv.hls); };
  pluginNames = [
    "class"
    "eval"
    "explicit-imports"
    "haddock-comments"
    "hlint"
    "retrie"
    "splice"
    "tactics"
  ];
  plugins =
    lib.foldl' lib.trivial.mergeAttrs {} (map plugin pluginNames);
  in builtins.listToAttrs versions // {
    ghcide = notest (subPkg "ghcide" "ghcide" niv.hls);
    shake-bench = notest (subPkg "shake-bench" "shake-bench" niv.hls);
    haskell-language-server = notest (cabal2nix "haskell-language-server" niv.hls);
    hie-compat = notest (subPkg "hie-compat" "hie-compat" niv.hls);
    hls-exactprint-utils = notest (subPkg "hls-exactprint-utils" "hls-exactprint-utils" niv.hls);
    hls-plugin-api = notest (subPkg "hls-plugin-api" "hls-plugin-api" niv.hls);
  } // plugins;
  finalGhc = ghc.override { overrides = pkgs.lib.composeExtensions (tools.derivationOverride false) deps; };
in {
  ghc = finalGhc;
  hls = pkgs.haskell.lib.justStaticExecutables finalGhc.haskell-language-server;
}
