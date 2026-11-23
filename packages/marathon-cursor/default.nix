{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "marathon-cursor";
  version = "0-unstable-2026-03-24";

  src = fetchFromGitHub {
    owner = "Woysful";
    repo = "Marathon-cursor";
    rev = "475a79c68bbabeeb415f2ebcd9189578b450e652";
    hash = "sha256-ZB7O+IJODQ42ebQdXO4dru178szC4J/Ix5nH8se6w3U=";
  };

  # Upstream names the themes "Marathon - bold" and "Marathon - regular";
  # install them without spaces so XCURSOR_THEME needs no quoting.
  installPhase = ''
    runHook preInstall
    for style in bold regular; do
      dir=$out/share/icons/Marathon-$style
      mkdir -p $dir
      cp -a "build/linux/Marathon - $style/cursors" $dir/
      sed "s/^Name=.*/Name=Marathon-$style/" "build/linux/Marathon - $style/index.theme" > $dir/index.theme
    done
    runHook postInstall
  '';

  meta = {
    description = "Marathon XCursor theme (bold and regular)";
    homepage = "https://github.com/Woysful/Marathon-cursor";
    platforms = lib.platforms.linux;
  };
}
