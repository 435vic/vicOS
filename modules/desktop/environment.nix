{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop;
in {
  options.vicos.desktop = {
    enable = mkEnableOption "Desktop environment";
    wayland.enable = mkEnableOption "Wayland";
    xorg.enable = mkEnableOption "X11";
    nix-ld.enable = mkEnableOption "nix-ld with steam-run libraries";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        libnotify
        xdg-utils
        playerctl
        libsForQt5.qt5ct
        adwaita-qt
        zed-editor.fhs #FIXME: move somewhere else maybe?
        nemo # file explorer
        (mpv.override {
          scripts = [ mpvScripts.webtorrent-mpv-hook ];
        })
      ];

      environment.sessionVariables = {
        XCURSOR_SIZE = "24";
        XCURSOR_THEME = mkDefault "Adwaita";
        GTK_THEME = mkDefault "Adwaita:dark";
        QT_STYLE_OVERRIDE = mkDefault "Adwaita-Dark";
        QT_QPA_PLATFORMTHEME = mkDefault "qt5ct";
      };


      services.udisks2.enable = true;
    }

    (mkIf cfg.wayland.enable {
      environment.systemPackages = with pkgs; [
        ripdrag # drag and drop
        wev # wayland event viewer
        wl-clipboard # clipboard
        swappy # screenshot tool
        slurp
        grim
        swayimg
        imv # image viewer
        libsForQt5.qt5.qtwayland
      ];
    })

    (mkIf cfg.nix-ld.enable {
      programs.nix-ld = {
        enable = true;
        # include a base set of libraries from steam-run
        # contains most of what normal, run of the mill packages
        # require
        libraries = pkgs.steam-run.args.multiPkgs pkgs;
      };
    })

    # TODO: X11
  ]);
}
