{
  appimageTools,
  fetchurl,
  widevine-cdm,
  lib,
  # Package options
  enableWideVine ? false,
}:
let
  pname = "helium";
  version = "0.6.9.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-L59Sm5qgORlV3L2yM6C0R8lDRyk05jOZcD5JPhQtbJE=";
  };

  contents = appimageTools.extract {
    inherit pname version src;
    postExtract = lib.optionalString enableWideVine ''
      chmod u+w $out/opt/helium
      cp -a ${widevine-cdm}/share/google/chrome/WidevineCdm $out/opt/helium/
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = contents;

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://github.com/imputnet/helium";
    platforms = [ "x86_64-linux" ];
    license = if enableWideVine then lib.licenses.unfree else lib.licenses.gpl3;
  };

  passthru = {
    appimageContents = contents;
  };

  extraInstallCommands = ''
    # Install desktop file and icon
    install -Dm644 ${contents}/helium.desktop $out/share/applications/${pname}.desktop
    install -Dm644 ${contents}/helium.png $out/share/icons/hicolor/256x256/apps/${pname}.png
    sed -i "s|^Exec=.*|Exec=${pname}|" $out/share/applications/${pname}.desktop
    sed -i "s|^Icon=.*|Icon=${pname}|" $out/share/applications/${pname}.desktop
  '';
}
