pkgs: rec {
  zed-editor = pkgs.callPackage ./zed {};
  zed-editor-fhs = zed-editor.fhs zed-editor;
}
