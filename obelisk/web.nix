{
  pkgs,
  niv,
  reflex,
  profiling,
  optimizationLevel,
  backend,
  frontend,
  assets,
}:
let
  asset = import ./assets.nix { inherit pkgs niv reflex optimizationLevel; };
in
  pkgs.runCommand "obelisk-web" {} ''
    mkdir $out
    set -eu
    ln -s '${if profiling then backend else pkgs.haskell.lib.justStaticExecutables backend}'/bin/* $out/
    ln -s '${asset.mkAssets assets}' $out/static.assets
    for d in '${asset.mkAssets (asset.compressedJs frontend)}'/*/; do
      ln -s "$d" "$out"/"$(basename "$d").assets"
    done
  ''
