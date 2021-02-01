{ pkgs, niv, reflex, optimizationLevel }:
let
  haskellLib = pkgs.haskell.lib;
in {
  inherit (import "${niv.obelisk}/lib/asset/assets.nix" { nixpkgs = pkgs; }) mkAssets;

  processAssets = { src, packageName ? "obelisk-generated-static", moduleName ? "Obelisk.Generated.Static" }: pkgs.runCommand "asset-manifest" {
    inherit src;
    outputs = [ "out" "haskellManifest" "symlinked" ];
    nativeBuildInputs = [ reflex.ghc.obelisk-asset-manifest ];
  } ''
    set -euo pipefail
    touch "$out"
    mkdir -p "$symlinked"
    obelisk-asset-manifest-generate "$src" "$haskellManifest" ${packageName} ${moduleName} "$symlinked"
  '';

  compressedJs = frontend: pkgs.runCommand "compressedJs" {} ''
    set -euo pipefail
    cd '${haskellLib.justStaticExecutables frontend}'
    shopt -s globstar
    for f in **/all.js; do
      dir="$out/$(basename "$(dirname "$f")")"
      mkdir -p "$dir"
      ln -s "$(realpath "$f")" "$dir/all.unminified.js"
      ${if optimizationLevel == null then ''
        ln -s "$dir/all.unminified.js" "$dir/all.js"
      '' else ''
        '${pkgs.closurecompiler}/bin/closure-compiler' --externs '${reflex.ghcjsExternsJs}' -O '${optimizationLevel}' --jscomp_warning=checkVars --create_source_map="$dir/all.js.map" --source_map_format=V3 --js_output_file="$dir/all.js" "$dir/all.unminified.js"
        echo '//# sourceMappingURL=all.js.map' >> "$dir/all.js"
      ''}
    done
  '';
}
