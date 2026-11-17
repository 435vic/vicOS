{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (builtins) isFloat isInt;
  cfg = config.vicos.hyprland;
  desktop = config.vicos.desktop;

  mkOpt = type: description:
    mkOption {
      inherit type description;
    };
  mkOpt' = type: description: default:
    mkOption {
      inherit type description default;
    };
  hyprlandMonitor = types.submodule {
    freeformType = types.attrsOf types.anything;

    options = {
      output = mkOpt types.str "output name or selector";
      mode = mkOpt' types.str "mode" "preferred";
      position = mkOpt' types.str "position" "auto";
      scale = mkOpt' (types.oneOf [types.int types.float types.str]) "scale" 1;
      disabled = mkOpt' types.bool "disabled" false;
      primary = mkOpt' types.bool "define this monitor as $monitor.primary" false;
      virtual = mkOpt' types.bool "create this output as a Hyprland headless monitor at startup" false;
    };
  };

  hyprpaperWallpaper = types.submodule {
    options = {
      monitor = mkOpt' types.str "monitor name or selector" "";
      fit_mode = mkOpt' types.str "fit mode (contain|cover|tile|fill)" "cover";
      path = mkOpt types.str "path to wallpaper or dir of wallpapers";
    };
  };
in {
  options.vicos.hyprland = {
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration to add to the Hyprland configuration file.";
    };

    monitors = mkOption {
      type = types.listOf hyprlandMonitor;
      description = "Hyprland monitor definitions. Entries are passed to hl.monitor, so arbitrary HL.MonitorSpec fields may be added in addition to the documented core options.";
      default = [];
    };

    hyprpaper.wallpapers = mkOption {
      type = types.listOf hyprpaperWallpaper;
      default = [];
      description = "Machine-specific Hyprpaper monitor declarations to write to ~/.config/hypr/hyprpaper.pre.conf.";
    };

    waybar.theme = mkOption {
      type = types.str;
      default = "rosepine";
      description = "Waybar theme directory under config/waybar/themes to link to ~/.config/waybar.";
    };

    primaryMonitor = mkOption {
      type = types.str;
      description = "Monitor to mark as primary.";
      default = "";
    };

    defaultEditor = mkOption {
      type = types.str;
      default = "zeditor";
      description = "Default editor to launch when inputting editor keybind.";
    };

    defaultBrowser = mkOption {
      type = types.str;
      default = "helium";
      description = "Default browser to launch when inputting browser keybind.";
    };

    defaultTerminal = mkOption {
      type = types.str;
      default = "ghostty";
      description = "Default terminal to launch when inputting terminal keybind.";
    };

    defaultFileManager = mkOption {
      type = types.str;
      default = "nautilus";
      description = "Default file manager to launch when inputting file manager keybind.";
    };

    environmentVariables = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "Environment variables to set in ~/.config/uwsm/env-hyprland.";
    };
  };

  config = {
    vicos.desktop.wayland.enable = true;

    assertions = [
      {
        assertion = builtins.all (m: !m.virtual || builtins.match "[A-Za-z0-9_-]+" m.output != null) cfg.monitors;
        message = ''
          vicos.hyprland.monitors: monitors with virtual = true are created as
          headless outputs, so output must be a plain name (e.g. "HEADLESS-1"),
          not a desc:/selector expression.
        '';
      }
    ];

    vicos.hyprland = let
      primaryMonitor = lib.findFirst (m: m.primary) {} cfg.monitors;
      primaryMonitorScale =
        if primaryMonitor ? scale && (isInt primaryMonitor.scale || isFloat primaryMonitor.scale)
        then primaryMonitor.scale
        else 1;
    in
      lib.mkMerge [
        {
          defaultEditor = lib.mkDefault desktop.apps.editor.command;
          defaultBrowser = lib.mkDefault desktop.apps.browser.command;
          defaultTerminal = lib.mkDefault desktop.apps.terminal.command;
          defaultFileManager = lib.mkDefault desktop.apps.fileManager.command;

          environmentVariables = {
            XCURSOR_SIZE = lib.mkDefault "24";
            XCURSOR_THEME = lib.mkDefault "Adwaita";
            HYPRCURSOR_SIZE = lib.mkDefault "24";
            HYPRCURSOR_THEME = lib.mkDefault "rose-pine-hyprcursor";
          };
        }
        (lib.mkIf (primaryMonitor ? output) {
          primaryMonitor = primaryMonitor.output;
        })
        (lib.mkIf (primaryMonitorScale > 1) {
          environmentVariables = {
            GDK_SCALE = toString (builtins.ceil primaryMonitorScale);
            XCURSOR_SIZE = toString (builtins.ceil primaryMonitorScale * 16);
          };
        })
      ];

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      TERMINAL = cfg.defaultTerminal;
    };
    environment.pathsToLink = ["/share/hypr"];

    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    security.pam.services = lib.genAttrs ["greetd" "greetd-password" "login"] (_: {
      enableGnomeKeyring = true;
      # Keep daemon startup, but never pass account passwords to a passwordless
      # keyring: a password-based login would silently re-encrypt it on save.
      rules.auth.gnome_keyring.enable = lib.mkForce false;
      rules.password.gnome_keyring.enable = lib.mkForce false;
    });
    services.dbus.packages = [
      pkgs.gnome-keyring
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };

    programs.waybar.enable = true;
    programs.hyprlock.enable = true;

    systemd = lib.mkMerge (map (pkg: {
      packages = [ pkgs.${pkg} ];
      user.services.${pkg}.wantedBy = [ "graphical-session.target" ];
    }) [
      "hyprpolkitagent"
      "hyprpaper"
    ]);


    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        hyprpicker # color picker
        hyprshot # screenshot tool
        hyprcursor # cursor support
        rose-pine-hyprcursor # better default cursor
        ;
    };

    services.displayManager = {
      ly = {
        enable = true;
        settings = let
          blackhole = pkgs.fetchurl {
            name = "blackhole.dur";
            url = "https://codeberg.org/attachments/f336d6ac-8331-4323-91fc-0e4619803401";
            hash = "sha256-fRm0wlkq9/GdLrVBOzMEnQG/i2ng+uGIzq0u9hu3m9g=";
          };
        in {
          animation = "dur_file";
          dur_file_path = "${blackhole}";
          full_color = true;
          bigclock = "en";
        };
      };
      defaultSession = "hyprland-uwsm";
      autoLogin = {
        enable = true;
        user = "vico";
      };
    };

    home.configFile = let
      toLua = lib.generators.toLua {};
      monitorSpec = monitor: removeAttrs monitor ["primary" "selector" "rawDefinition" "disable" "virtual"];
    in {
      hypr = {
        source = config.lib.vicos.stash "config/hypr";
        recursive = true;
      };

      waybar = {
        source = config.lib.vicos.stash "config/waybar/themes/${cfg.waybar.theme}";
        recursive = true;
      };

      "uwsm/env-hyprland".text = lib.pipe cfg.environmentVariables [
        (lib.mapAttrsToList (n: v: "export ${lib.escapeShellArg n}=${lib.escapeShellArg v}"))
        lib.concatLines
      ];

      mako = {
        source = config.lib.vicos.stash "config/mako";
        recursive = true;
      };

      "hypr/hyprpaper.nix.conf".text = let
        # monitor key must go first to allow empty vals for fallback
        monitor = w: "monitor = ${w.monitor}";
        rest = w: removeAttrs w [ "monitor" ];
      in lib.concatMapStringsSep "\n" (w: ''
        wallpaper {
          ${monitor w}
          ${builtins.concatStringsSep "\n  " (lib.mapAttrsToList (k: v: "${k} = ${v}") (rest w))}
        }
      '') cfg.hyprpaper.wallpapers;

      "hypr/nixvars.lua".text = ''
        return ${toLua {
          programs = {
            terminal = cfg.defaultTerminal;
            browser = cfg.defaultBrowser;
            editor = cfg.defaultEditor;
            file = cfg.defaultFileManager;
          };
          monitor =
            {
              monitors = map monitorSpec cfg.monitors;
              virtual = map (m: m.output) (builtins.filter (m: m.virtual) cfg.monitors);
            }
            // lib.optionalAttrs (cfg.primaryMonitor != "") {
              primary = cfg.primaryMonitor;
            };
        }}
      '';
    };
  };
}
