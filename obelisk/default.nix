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

  emptyDir = pkgs.runCommand "empty-dir" {} ''
    mkdir -p $out
    touch $out/config.files
  '';

  reflexOptions = def: def // {
    packages = {};
    shells = {
      ghc = [];
      ghcjs = [];
      android = [];
    };
    android = def.android // {
      frontend = def.android.frontend // {
        executableName = "frontend";
        assets = emptyDir;
      };
    };
  };

  project = reflex.project (args: reflexOptions (projectDef args.pkgs));
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
