pkgs: rec {
  zed-editor = pkgs.callPackage ./zed {};
  zed-editor-base = zed-editor.zed-base;
}
