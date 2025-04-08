{
  config,
  pkgs,
  lib,
  ...
}: with lib; let
  cfg = config.vicos.desktop.apps.cad;
  kicad = pkgs.runCommand "kicad" {
    buildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir $out
    ln -s ${pkgs.kicad-small}/* $out
    rm $out/bin
    mkdir $out/bin
    ln -s ${pkgs.kicad-small}/bin/* $out/bin
    rm $out/bin/kicad
    # kicad isn't really working on wayland right now
    makeWrapper ${pkgs.kicad-small}/bin/kicad $out/bin/kicad \
      --set-default GDK_BACKEND x11
  '';
in {
  options = {
    vicos.desktop.apps.cad = {
      enable = mkEnableOption "cad software";
      kicad = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable kicad";
        };
        package = mkOption {
          type = types.package;
          default = kicad;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    vicos.user.packages = mkMerge [
      (mkIf cfg.kicad.enable [ cfg.kicad.package ])
    ];
  };
}
