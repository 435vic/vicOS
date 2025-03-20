{
  appimageTools,
  fetchurl,
  lib,
  ...
}: let
  pname = "viper";
  version = "1.12.1";

  src = fetchurl {
    url = "https://github.com/0neGal/${pname}/releases/download/v${version}/${pname}-${version}.AppImage";
    hash = "sha256-VjE3doKnEIS+N97yBz+NnNqHv9xQZb3yRD4hhhn6SKo=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
      cp -r ${appimageContents}/usr/share/icons $out/share
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    '';

    meta = {
      description = "Launcher+Updater for TF|2 Northstar";
      homepage = "https://github.com/0neGal/viper";
      license = lib.licenses.gpl3Only;
      mainProgram = "viper";
      maintainers = with lib.maintainers; [NotAShelf];
      platforms = ["x86_64-linux"];
    };
  }
