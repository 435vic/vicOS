{
  description = "Basic C/C++ flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        clang-tools
        cmake
        codespell
        conan
        cppcheck
        doxygen
        gtest
        lcov
        vcpkg
        vcpkg-tool
      ];
    };
  }
  );
}