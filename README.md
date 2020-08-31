# About

A set of tools for developing on a Haskell project with Nix build.
Provides out of the box-setup for package overrides, `ghcid`, `ghcide`, [thax],
and `cabal` commands.

# Basic usage

`default.nix`:

```nix
let
  niv = import "${toString base}/nix/sources.nix";
  hs = import (fetchTarball "https://github.com/tek/tryp-hs/archive/master.tar.gz") { base = ./.; };
  packages = {
    frontend = ./packages/frontend;
    backend = ./packages/backend;
  };

  overrides = { pkgs, hackage }:
    self: super:
    let
      versions = [
        (hackage.pack "relude" "0.7.0.0" "0flrwzxdd9bd3knk48zkhadwlad01msskjby1bfv4snr44q5xfqd")
      ];
      versionOverrides = builtins.listToAttrs versions;
      custom = {
        chronos = hackage.cabal2nix "chronos" niv.chronos;
      };
    in
      versionOverrides // custom;

  commands = {
    exe = {
    script = ''
      :load Main
      :import Main
    '';
    test = "main";
      extraSearch = ["packages/backend/app"];
    };
  };
in
  hs.project {
    inherit packages base overrides commands;
    compiler = "ghc8101";
    cabal2nixOptions = "--no-hpack";
    ghciArgs = ["-hide-package" "base" "-Wall" "-Werror"];
    options_ghc = "-fplugin=Polysemy.Plugin";
    packageDir = "packages";
  }
```

## ghcid

Now you can run a `ghcid` session that runs the executable in
`packages/backend/app`, has all dependencies and searches for modules in the
directories specified in `packages`:

`
$ nix-shell --pure -A ghcid.exe --run exit`

## ghcide

Put this in your `hie-bios.sh`:

```sh
#!/usr/bin/env bash

nix eval --raw -f default.nix ghcid.ghcide-conf > "$HIE_BIOS_OUTPUT"
```

## hasktags

To generate `ctags` for all dependencies and project packages:

```sh
#!/usr/bin/env bash

cp $(nix-build --no-link -A tags.projectTags)/tags .tags
chmod u+w .tags
```

## cabal

Run `cabal` commmands, like `sdist`, on a package:

```sh
nix-shell -A cabal.backend.sdist
```

## Build

To build a package with nix:

```sh
nix-build -A ghc.backend
```

[thax]: https://github.com/tek/thax
