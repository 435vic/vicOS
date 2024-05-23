pkgs: rec {
  zed-editor = pkgs.callPackage ./zed {};
  zed-editor-fhs = pkgs.callPackage ./zed/fhsenv.nix {};
}
