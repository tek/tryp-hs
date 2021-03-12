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
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      (pack "apply-refact" "0.9.0.0" "1vxxzfajg248lk4s6lh1jjkn1rym8x6zs5985i5kpz989k6cpyx5")
      (pack "brittany" "0.13.1.0" "172mg0ch2awfzhz8vzvjrfdjylfzawrbgfr5z82l1qzjh6g9z295")
      (jpack "data-tree-print" "0.1.0.2" "12k7m0xqzslzlj38v4072cscmhk1y9hdj6ck4c87dj5p2da6f8qz")
      (pack "fourmolu" "0.3.0.0" "05b8ksifahahha3ra1mjby1gr9ysm5jc8li09v40l36z8n370l28")
      (pack "ghc-exactprint" "0.6.3.4" "1405vkc6kaj01yygl3d3yd7c57dhpipbkvgngz9pv5v3ammfnzmq")
      (pack "haskell-lsp" "0.23.0.0" "0d9bk1cqkk41frm81j683h2vd1hghl4hlvj8g17690d2qk5pq3c0")
      (pack "haskell-lsp-types" "0.23.0.0" "17mfc2zxkbwipxiy0g3qwqnyp8ds4mrg0z1v7jchcm89hnf8mmmq")
      (pack "heapsize" "0.3.0.1" "0c8lqndpbx9ahjrqyfxjkj0z4yhm1zlcn8al0ir4ldlahql2xv3r")
      (pack "hiedb" "0.3.0.1" "0n6m13lybnb6vl0lh69i2v6xykcd0bl5svkk18964k4wza8a5b12")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "implicit-hie-cradle" "0.3.0.2" "1fhc8zccd7g7ixka05cba3cd4qf5jvq1zif29bhn593dfkzy89lz")
      (pack "implicit-hie" "0.1.2.5" "1l0rz4r4hamvmqlb68a7y4s3n73y6xx76zyprksd0pscd9axznnv")
      (pack "lsp" "1.1.1.0" "0lcqiw5304llxamizza28xy4llhmmrr3dkvlm4pgrhzfcxqwnfrm")
      (pack "lsp-types" "1.1.0.0" "1l8g7iq9zsq19hxamy37hf61bmld500pha2xcwwqs7hk53k9wgn8")
      (pack "lsp-test" "0.13.0.0" "1b0p678bh4h1mfbi1v12g9zhnyhgq5q3fiv491ni461v44ypr6bn")
      (pack "megaparsec" "9.0.1" "1279c0snq1w13scikiakdm25ybpnvbpm7khjq4wyy0gj1vvh8r6z")
      (pack "opentelemetry" "0.6.1" "08k71z7bns0i6r89nmxqsl00kyksicq619rqy6pf5m7hq1r4zs9m")
      (pack "refinery" "0.3.0.0" "08s5pw6j3ncz96zfc2j0cna2zbf4vy7045d6jpzmq2sa161qnpgi")
      (pack "stylish-haskell" "0.12.2.0" "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr")
      (pack "uniplate" "1.6.13" "01p79pxmgdq8ya8llwrip5awc521y6qdchqw18ydkkidglv5m3bj")
      (jpack "unliftio-core" "0.2.0.0" "1l3nkrp09md97bm1s5vgsk776858gkkzccxi0zw7kfxg59p4x4ap")
    ];
  plugin = n:
  let
    name = "hls-${n}-plugin";
  in
    { ${name} = notest (subPkg "plugins/hls-${n}-plugin" "hls-${n}-plugin" niv.hls); };
  pluginNames = [
    "brittany"
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
