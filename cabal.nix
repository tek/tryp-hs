{
  packages,
  ghcid,
}:
let
  shell = cmd:
  ghcid.shellWith {
    hook = ''
      ${cmd}
      exit
    '';
  };
  command = args:
  shell "cabal ${args}";

  package = name: path:
  let
    buildDir = "/tmp/${name}-build";
    buildDirOption = "--builddir ${buildDir}";
    pkgCommand = args: command "${args} ${buildDirOption} ${name}";
    nameUnderscore = builtins.replaceStrings ["-"] ["_"] name;
    docOptions = "--enable-documentation --haddock-for-hackage --haddock-options '--hide Paths_${nameUnderscore}'";
    srcFile = "${buildDir}/${name}-?.?.?.?.tar.gz";
    docFile = "${buildDir}/${name}-?.?.?.?-docs.tar.gz";
  in {
    build = pkgCommand "v2-build ${docOptions}";
    doc = pkgCommand "v2-haddock ${docOptions}";
    genBounds = shell ''
      cd ${path}
      cabal gen-bounds
    '';
    sdist = pkgCommand "v2-sdist -o ${buildDir}";
    uploadSrc = command "upload ${srcFile}";
    uploadDoc = command "upload -d ${docFile}";
    publishSrc = command "upload --publish ${srcFile}";
    publishDoc = command "upload -d --publish ${docFile}";
  };

in
  builtins.mapAttrs package packages
