{ niv }:
self: super:

let
  inherit (self) lib;
in {
  obeliskExecutableConfig = self.callPackage "${niv.obelisk}/lib/executable-config" {
    obeliskCleanSource = lib.cleanSource;
  };
}
