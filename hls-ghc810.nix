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
      (pack "aeson" "1.5.2.0" "0rz7j7bcj5li2c5dmiv3pnmbs581vzkl9rbx9wq2v06f4knaklkf")
      (jpack "data-tree-print" "0.1.0.2" "12k7m0xqzslzlj38v4072cscmhk1y9hdj6ck4c87dj5p2da6f8qz")
      (pack "ghc-exactprint" "0.6.3.2" "0l9piqqgdi8xd46nj1jizp0r0v526d7f61y05xm8k4aamjaj59d0")
      (pack "hie-bios" "0.7.1" "137f1dy0fmlrzngwcmgnxghcih7f2rfq5bdnizbwy9534dn4dr42")
      (pack "lsp-test" "0.11.0.7" "160w3a5mmgjwfgmdrv2ahb4j5r9axc0y52limyrps8nb2s0xrqbf")
      (pack "refinery" "0.3.0.0" "08s5pw6j3ncz96zfc2j0cna2zbf4vy7045d6jpzmq2sa161qnpgi")
      (pack "stylish-haskell" "0.12.2.0" "1ck8i550rvzbvzrm7dvgir73slai8zmvfppg3n5v4igi7y3jy0mr")
    ];
  in builtins.listToAttrs versions // {
    brittany = cabal2nix "brittany" niv.brittany-810;
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
