{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.vicos.theme;
in {
  options.vicos.theme = {
    active = mkOption {
      type = types.str;
      description = "Theme to apply to system.";
      default = "rose-pine";
    };

    gtk = {
      package = mkOption {
        type = types.package;
        description = "GTK theme package for current active theme.";
      };
      iconPackage = mkOption {
        type = types.package;
        description = "GTK icon theme package for current active theme.";
      };

      name = mkOption {
        type = types.str;
        description = "Name of the GTK theme";
      };

      iconName = mkOption {
        type = types.str;
        description = "Name of the GTK icon theme";
      };
    };

    cursor = {
      package = mkOption {
        type = types.package;
        description = "Cursor package";
      };

      hyprcursorPackage = mkOption {
        type = types.package;
        description = "Hyprcursor package";
      };

      name = mkOption {
        type = types.str;
        description = "xcursor theme name";
      };

      hyprcursorName = mkOption {
        type = types.str;
        description = "hyprcursor theme name";
      };
    };
  };

  config = {
    #home.configFile = {
    #  "gtk-3.0/settings.ini".text = ''
    #    gtk-theme-name=${cfg.gtk.name}
    #    gtk-icon-theme-name=${cfg.gtk.iconName}
    #    gtk-cursor-theme-name=${cfg.cursor.name}
    #  '';

    #  "gtk-4.0/gtk.css".source =
    #    "${cfg.gtk.package}/share/themes/rose-pine/gtk-4.0/gtk.css";
    #};

    vicos.user.packages = [
      cfg.cursor.package
      cfg.cursor.hyprcursorPackage
      cfg.gtk.package
      cfg.gtk.iconPackage
    ];

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = cfg.cursor.name;
              icon-theme = cfg.gtk.iconName;
              gtk-theme = cfg.gtk.name;
            };
          };
        }
      ];
    };

    vicos.desktop.hyprland.environmentVariables = {
      XCURSOR_THEME = cfg.cursor.name;
      XCURSOR_SIZE = "24";
      GTK_THEME = mkForce cfg.gtk.name;
      HYPRCURSOR_THEME = cfg.cursor.hyprcursorName;
      HYPCURSOR_SIZE = "24";
    };
  };
}
