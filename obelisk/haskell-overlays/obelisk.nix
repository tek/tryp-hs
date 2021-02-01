{
  niv,
}:
self: super:
let
  pkgs = self.callPackage ({ pkgs }: pkgs) {};
  haskellLib = pkgs.haskell.lib;
  onLinux = pkg: f: if pkgs.stdenv.isLinux then f pkg else pkg;
  obLib = p: n:
  haskellLib.dontHaddock (haskellLib.appendConfigureFlag (self.callCabal2nix p "${niv.obelisk}/lib/${n}" {}) "--ghc-option=-Wno-all");
in {
  shelly = self.callHackage "shelly" "1.9.0" {};
  snap-core = haskellLib.dontCheck (self.callCabal2nix "snap-core" niv.snap-core {});
  obelisk-executable-config-inject = pkgs.obeliskExecutableConfig.platforms.web.inject self;

  obelisk-asset-manifest = obLib "obelisk-asset-manifest" "asset/manifest";
  obelisk-asset-serve-snap = obLib "obelisk-asset-serve-snap" "asset/serve-snap";
  obelisk-backend = obLib "obelisk-backend" "backend";
  obelisk-cliapp = obLib "obelisk-cliapp" "cliapp";
  obelisk-command = haskellLib.overrideCabal (obLib "obelisk-command" "command") {
    librarySystemDepends = [
      pkgs.jre
      pkgs.git
      pkgs.nix
      pkgs.nix-prefetch-git
      pkgs.openssh
      pkgs.rsync
      pkgs.which
      (haskellLib.justStaticExecutables self.ghcid)
    ];
  };
  obelisk-frontend = obLib "obelisk-frontend" "frontend";
  obelisk-run = onLinux (obLib "obelisk-run" "run") (pkg:
    haskellLib.overrideCabal pkg (drv: { librarySystemDepends = [ pkgs.iproute ]; })
  );
  obelisk-route = obLib "obelisk-route" "route";
  obelisk-selftest = haskellLib.overrideCabal (obLib "obelisk-selftest" "selftest") {
    librarySystemDepends = [
      pkgs.cabal-install
      pkgs.coreutils
      pkgs.git
      pkgs.nix
      pkgs.nix-prefetch-git
      pkgs.rsync
    ];
  };
  obelisk-snap-extras = obLib "obelisk-snap-extras" "snap-extras";
  tabulation = obLib "tabulation" "tabulation";
}
