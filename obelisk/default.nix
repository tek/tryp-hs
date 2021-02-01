niv:
{
  projectDef,
  system ? builtins.currentSystem,
  profiling ? false,
  config ? {},
  reflex-platform-func ? import niv.reflex-platform,
  optimizationLevel ? "ADVANCED"
}:
let
  reflex = reflex-platform-func {
    inherit config system;
    enableLibraryProfiling = profiling;
    nixpkgsOverlays = [(import ./nixpkgs-overlays { inherit niv; })];
    haskellOverlays = [
      pkgs.obeliskExecutableConfig.haskellOverlay
      (import ./haskell-overlays/obelisk.nix { inherit niv; })
    ];
  };
  pkgs = reflex.nixpkgs;

  reflexDummyArgs = {
    packages = {};
    shells = {
      ghc = [];
      ghcjs = [];
      android = [];
    };
  };

  project = reflex.project (args: projectDef args.pkgs // reflexDummyArgs);
in {
  inherit pkgs reflex project;
  profiled = import ./profiled.nix project.ghc;
  web = import ./web.nix {
    inherit pkgs niv reflex profiling optimizationLevel;
    inherit (project.ghc) backend;
    inherit (project.ghcjs) frontend;
    assets = "/var/empty";
  };
}
