{
  config,
  pkgs,
  lib,
  ...
}: with lib; let
  cfg = config.vicos.desktop.apps.cad;
  kicad = pkgs.runCommand "kicad" {
    buildInputs = [ pkgs.makeWrapper ];
    binaries = [ "kicad" "gerbview" "bitmap2component" "pl_editor" "eeschema" "pcb_calculator" "pcbnew" ];
  } ''
    mkdir $out
    ln -s ${pkgs.kicad-small}/* $out
    rm $out/bin
    mkdir $out/bin
    ln -s ${pkgs.kicad-small}/bin/* $out/bin
    # kicad isn't really working on wayland right now
    for binary in $binaries; do
      rm $out/bin/$binary
      makeWrapper ${pkgs.kicad-small}/bin/$binary $out/bin/$binary \
        --set-default GDK_BACKEND x11
    done
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
