{
  description = "haskell development build tools";
  inputs = {
    nixpkgs.url = github:NixOs/nixpkgs?rev=cfed29bfcb28259376713005d176a6f82951014a;
    brittany = {
      url = github:bubba/brittany;
      flake = false;
    };
    hls = {
      url = github:haskell/haskell-language-server;
      flake = false;
    };
    obelisk = {
      url = github:obsidiansystems/obelisk;
      flake = false;
    };
    reflex-platform = {
      url = git+https://gitlab.tryp.io/nix/reflex-platform.git?ref=tryp;
      flake = false;
    };
    snap-core = {
      url = github:obsidiansystems/snap-core?ref=ts-expose-fileserve-internals;
      flake = false;
    };
    thax = {
      url = github:tek/thax;
      flake = false;
    };
  };
  outputs = inputs: import ./main.nix inputs;
}
