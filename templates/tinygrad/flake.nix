
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    tinygrad = {
      url = "github:tinygrad/tinygrad/master";
      flake = false;
    };
  };

  outputs = { nixpkgs, tinygrad }: let
    inherit (nixpkgs) lib;
    systems = [ "x86_64-linux" ];
    mkPkgs = system: import nixpkgs {
      inherit system;
      config = {
        rocmSupport = true;
      };
    };
    perSystem = pred: lib.genAttrs systems
      (system: 
        pred {
          inherit system;
          pkgs = mkPkgs system;
        });
    tinygradPkg = (import ./nix/tinygrad { src = tinygrad; version = "master-${tinygrad.shortRev}"; });

    python = pkgs:
      let
        python = pkgs.python3.override {
          self = python;
          packageOverrides = pyfinal: pyprev: {
            tinygrad = pyfinal.callPackage tinygradPkg {};
          };
        };
      in
      python;
  in {
    packages = perSystem ({ pkgs, ... }: {
      tinygrad = (python pkgs).pkgs.tinygrad;
    });

    devShells = perSystem ({ pkgs }: {
      default = pkgs.mkShell {
        packages = [
          ((python pkgs).withPackages (ps: builtins.attrValues {
            inherit (ps)
              numpy
              jupyter
              pandas
              tinygrad;
          })) 
        ];
      };
    });
  };
}
