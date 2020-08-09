hackage:
{
  packages ? {},
  overrides ? _: _: {},
  cabal2nixOptions ? "",
}:
let
  nixpkgs = import <nixpkgs> {};
  local = notest: ghc: n: s:
    notest (ghc.callCabal2nixWithOptions n s cabal2nixOptions {});
  localOverrides = self: super:
    let
      hack = hackage { pkgs = nixpkgs; inherit self super; };
    in
      builtins.mapAttrs (local hack.notest self) packages;
in
  nixpkgs.lib.composeExtensions localOverrides overrides
