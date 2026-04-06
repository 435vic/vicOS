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
  version = "0.10.8.1";
  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/0.10.8.1/helium-0.10.8.1-x86_64_linux.tar.xz";
    hash = "sha256-qu0GvCbg4Eq1cHrTerOzH98KkL0FCSVQgLe+QWyH9d4=";
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
