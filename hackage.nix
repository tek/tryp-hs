{
  pkgs,
  self,
  super,
}:
let
  hl = pkgs.haskell.lib;
  unbreak = hl.unmarkBroken;
  notest = p:
    hl.doHaddock (hl.dontBenchmark (hl.dontCheck (unbreak p)));
  jailbreak = hl.doJailbreak;
  hackage = { pkg, ver, sha256 }:
    notest (self.callHackageDirect { inherit pkg ver sha256; } {});
  cabal2nix = name: src:
    notest (self.callCabal2nix name src {});
  curated = pkg: ver:
    notest (self.callHackage pkg ver {});
  subPkg = dir: name: src:
    notest (self.callCabal2nixWithOptions name src "--subpath ${dir}" {});
  github = args@{ repo, ... }:
    jailbreak (cabal2nix repo (pkgs.fetchFromGitHub args));
in {
  inherit unbreak notest jailbreak hackage cabal2nix curated subPkg github;
  pack = pkg: ver: sha256:
    { name = pkg; value = hackage { inherit pkg ver sha256; }; };
  jpack = pkg: ver: sha256:
    { name = pkg; value = jailbreak (hackage { inherit pkg ver sha256; }); };
  unbreakSuper = name: notest (builtins.getAttr name super);
}
