{ haskellNix ? ../deps/haskell.nix
}:

{ project ? null # nix-haskell haskell.nix project attr set
, targets # { String (Platform): [String (Compiler) || { compiler :: String, project :: nix-haskell haskell.nix project attr set }] }
}:

let haskell = import ../deps/nix-haskell { inherit haskellNix; };
    pkgs = haskell.pkgs;

    makeProject = platform: compiler: proj:
      let haskell = import ../deps/nix-haskell { inherit haskellNix; crossPlatform = platform; };
      in haskell.project (proj // { project = proj.project // { compiler-nix-name = compiler; }; });

    perTarget = with pkgs.lib;
      builtins.mapAttrs (platform: compilers:
        builtins.listToAttrs (forEach compilers (compiler:
          if builtins.isString compiler
          then { name = compiler; value = makeProject platform compiler project; }
          else { name = compiler.compiler; value = makeProject platform compiler.compiler compiler.project; }
        ))
      ) targets;

in with pkgs.lib; pkgs.runCommand "ci-haskell.nix" {} ''
  mkdir -p $out

  ${
    concatStringsSep "\n"
      (forEach (builtins.attrNames perTarget) (platform:
        concatStringsSep "\n"
          (forEach (builtins.attrNames perTarget.${platform}) (compiler: ''
            mkdir -p "$out/${platform}"
            ln -s "${perTarget.${platform}.${compiler}.projectCoverageReport}" "$out/${platform}/${compiler}"
          ''))
      ))
  }
''
