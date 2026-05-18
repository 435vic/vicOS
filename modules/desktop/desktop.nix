{
  pkgs,
  lib,
  config,
  vicos ? {},
  ...
}: let
  cfg = config.vicos.desktop;
  hasHelium = vicos ? packages && vicos.packages ? helium;

  desktopApp = lib.types.submodule {
    options = {
      package = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package providing this desktop application.";
      };

      command = lib.mkOption {
        type = lib.types.str;
        description = "Command used to launch this application from scripts/keybinds.";
      };

      desktop = lib.mkOption {
        type = lib.types.str;
        description = "Desktop entry ID used for XDG defaults.";
      };
    };
  };

  packagedApps = lib.pipe cfg.apps [
    builtins.attrValues
    (map (app: app.package))
    (builtins.filter (pkg: pkg != null))
  ];

  themePackages =
    lib.pipe [
      cfg.theme.gtk.package
      cfg.theme.icon.package
    ] [
      (builtins.filter (pkg: pkg != null))
    ];
in {
  options.vicos.desktop = {
    wayland.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable wayland programs and tools";
      default = false;
    };

    apps = {
      terminal = lib.mkOption {
        type = desktopApp;
        description = "Default terminal emulator.";
        default = {
          package = pkgs.ghostty;
          command = "ghostty";
          desktop = "com.mitchellh.ghostty.desktop";
        };
      };

      browser = lib.mkOption {
        type = desktopApp;
        description = "Default web browser.";
        default = {
          package =
            if hasHelium
            then vicos.packages.helium
            else pkgs.firefox;
          command =
            if hasHelium
            then "helium"
            else "firefox";
          desktop =
            if hasHelium
            then "helium.desktop"
            else "firefox.desktop";
        };
      };

      editor = lib.mkOption {
        type = desktopApp;
        description = "Default graphical text editor.";
        default = {
          package = pkgs.zed-editor;
          command = "zeditor";
          desktop = "dev.zed.Zed.desktop";
        };
      };

      fileManager = lib.mkOption {
        type = desktopApp;
        description = "Default graphical file manager.";
        default = {
          package = pkgs.nautilus;
          command = "nautilus";
          desktop = "org.gnome.Nautilus.desktop";
        };
      };

      pdfViewer = lib.mkOption {
        type = desktopApp;
        description = "Default PDF/document viewer.";
        default = {
          package = pkgs.zathura;
          command = "zathura";
          desktop = "org.pwmt.zathura-pdf-mupdf.desktop";
        };
      };

      imageViewer = lib.mkOption {
        type = desktopApp;
        description = "Default image viewer.";
        default = {
          package = pkgs.imv;
          command = "imv";
          desktop = "imv.desktop";
        };
      };

      mediaPlayer = lib.mkOption {
        type = desktopApp;
        description = "Default audio/video player.";
        default = {
          package = pkgs.mpv;
          command = "mpv";
          desktop = "mpv.desktop";
        };
      };

      mailClient = lib.mkOption {
        type = desktopApp;
        description = "Default mail client.";
        default = {
          package = pkgs.thunderbird;
          command = "thunderbird";
          desktop = "thunderbird.desktop";
        };
      };
    };

    theme = {
      colorScheme = lib.mkOption {
        type = lib.types.enum [
          "default"
          "prefer-dark"
          "prefer-light"
        ];
        default = "prefer-dark";
        description = "Freedesktop/GNOME color-scheme preference.";
      };

      gtk = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "adw-gtk3-dark";
          description = "GTK theme name.";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.adw-gtk3;
          description = "Package providing the GTK theme.";
        };
      };

      icon = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "Papirus-Dark";
          description = "Icon theme name.";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.papirus-icon-theme;
          description = "Package providing the icon theme.";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      environment.systemPackages =
        (builtins.attrValues {
          inherit
            (pkgs)
            libnotify
            xdg-utils
            xdg-terminal-exec
            playerctl
            adwaita-qt
            ripdrag
            mako # notification daemon
            pamixer # volume control
            brightnessctl # backlight control
            btop # process manager
            vesktop # discord client
            bitwarden-desktop
            ;
        })
        ++ packagedApps ++ themePackages;

      programs.localsend.enable = true;

      # DARK MODEEEE
      programs.dconf = {
        enable = true;
        profiles.user.databases = [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                color-scheme = cfg.theme.colorScheme;
                gtk-theme = cfg.theme.gtk.name;
                icon-theme = cfg.theme.icon.name;
              };
            };
          }
        ];
      };

      home.configFile = {
        "gtk-3.0/settings.ini".text = ''
          [Settings]
          gtk-application-prefer-dark-theme=1
          gtk-theme-name=${cfg.theme.gtk.name}
          gtk-icon-theme-name=${cfg.theme.icon.name}
        '';

        "gtk-4.0/settings.ini".text = ''
          [Settings]
          gtk-application-prefer-dark-theme=1
          gtk-theme-name=${cfg.theme.gtk.name}
          gtk-icon-theme-name=${cfg.theme.icon.name}
        '';

        "xdg-terminals.list".text = ''
          ${cfg.apps.terminal.desktop}
        '';
      };
    }
    (lib.mkIf cfg.wayland.enable {
      environment.systemPackages = builtins.attrValues {
        inherit
          (pkgs)
          wev
          wl-clipboard
          swappy
          swayimg
          imv
          ;
      };
    })
  ];
}
