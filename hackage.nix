{ pkgs, self, super, }:
let
  unbreak = pkgs.haskell.lib.unmarkBroken;
  notest = p:
    pkgs.haskell.lib.dontBenchmark (pkgs.haskell.lib.dontCheck (unbreak p));
  jailbreak = pkgs.haskell.lib.doJailbreak;
  hackage = { pkg, ver, sha256 }:
    notest (self.callHackageDirect { inherit pkg ver sha256; } {});
  cabal2nix = name: src:
    notest (self.callCabal2nix name src {});
  curated = pkg: ver:
    notest (self.callHackage pkg ver {});
  subPkg = dir: name: src:
      notest (self.callCabal2nixWithOptions name src "--subpath ${dir}" {});
in {
  inherit unbreak notest jailbreak hackage cabal2nix curated subPkg;
  pack = pkg: ver: sha256:
    { name = pkg; value = hackage { inherit pkg ver sha256; }; };
  jpack = pkg: ver: sha256:
    { name = pkg; value = jailbreak (hackage { inherit pkg ver sha256; }); };
  unbreakSuper = name: notest (builtins.getAttr name super);
}
