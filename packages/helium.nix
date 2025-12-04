{ appimageTools, fetchurl }:
let
  pname = "helium";
  version = "0.6.9.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-L59Sm5qgORlV3L2yM6C0R8lDRyk05jOZcD5JPhQtbJE=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  meta = {
    platforms = [ "x86_64-linux" ];
  };

  passthru = {
    appimageContents = contents;
  };

  extraInstallCommands = ''
    install -Dm644 ${contents}/helium.desktop $out/share/applications/${pname}.desktop
    install -Dm644 ${contents}/helium.png $out/share/icons/hicolor/256x256/apps/${pname}.png
    sed -i "s|^Exec=.*|Exec=${pname}|" $out/share/applications/${pname}.desktop
    sed -i "s|^Icon=.*|Icon=${pname}|" $out/share/applications/${pname}.desktop
  '';
}
