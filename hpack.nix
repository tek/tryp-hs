{ base, pkgs }:
let
  script = pkgs.writeScript "hpack.zsh" ''
    #!${pkgs.zsh}/bin/zsh
    setopt err_exit no_unset

    base="${toString base}"
    hpack="$base/ops/hpack"

    gen()
    {
      local dir=$1
      pushd $dir
      cp $hpack/packages/''${dir:t}.yaml $dir/package.yaml
      ln -srf $hpack/shared $dir/shared
      trap "rm -f $dir/package.yaml $dir/shared" EXIT
      hpack 1>/dev/null
      popd
    }

    for m ($base/packages/*) gen $m
  '';
in
  pkgs.mkShell {
    name = "hpack";
    shellHook = script;
  }
