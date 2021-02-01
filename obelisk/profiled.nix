{pkgs, ghc}:
let
  exeSource = builtins.toFile "ob-run.hs" ''
    {-# LANGUAGE NoImplicitPrelude #-}
    {-# LANGUAGE PackageImports #-}
    module Main where

    -- Explicitly import Prelude from base lest there be multiple modules called Prelude
    import "base" Prelude (IO, (++), read)

    import "base" Control.Exception (finally)
    import "reflex" Reflex.Profiled (writeProfilingData)
    import "base" System.Environment (getArgs)

    import qualified "obelisk-run" Obelisk.Run
    import qualified Frontend
    import qualified Backend

    main :: IO ()
    main = do
      [portStr, assets, profFileName] <- getArgs
      Obelisk.Run.run (read portStr) (Obelisk.Run.runServeAsset assets) Backend.backend Frontend.frontend
        `finally` writeProfilingData (profFileName ++ ".rprof")
  '';
in pkgs.runCommand "ob-run" { buildInputs = [ (ghc.ghcWithPackages (p: [p.backend p.frontend])) ]; } ''
  cp ${exeSource} ob-run.hs
  mkdir -p $out/bin
  ghc -x hs -prof -fno-prof-auto -threaded ob-run.hs -o $out/bin/ob-run
''
