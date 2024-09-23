{ haskellNix ? ./deps/haskell.nix
}:

let haskell-nix = with haskell-nix; {
      buildMatrix = import ./haskell.nix { inherit haskellNix; };

      compilers = {
        default = [ "ghc90" "ghc92" "ghc94" "ghc96" "ghc98" "ghc910" ];
        ghc-js = [ "ghc98" "ghc910" ];
      };

      matrix = {
        default = {
          "gnu64" = compilers.default;
          "ghcjs" = compilers.ghc-js;
        };
      };

      pin = haskellNix;
    };

in {
  nix-haskell = import ./deps/nix-haskell { inherit haskellNix; };
  inherit haskell-nix;
}
