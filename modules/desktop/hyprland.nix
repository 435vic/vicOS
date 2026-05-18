{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
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
  hyprlandMonitor = types.submodule (
    {config, ...}: {
      options = {
        output = mkOpt types.str "output";
        selector = mkOpt' types.str "more specific selector (see wiki)" "";
        mode = mkOpt' types.str "mode" "preferred";
        position = mkOpt' types.str "position" "auto";
        scale = mkOpt' types.int "scale" 1;
        disable = mkOpt' types.bool "disabled" false;
        primary = mkOpt' types.bool "define this monitor as $monitor.primary" false;
        rawDefinition = mkOpt types.str "final monitor declaration";
      };

      config = lib.mkMerge [
        (lib.mkIf (config.selector != "") {
          output = config.selector;
        })
        {
          rawDefinition =
            if config.disable
            then "monitor = ${config.output},disable"
            else "monitor = ${config.output},${config.mode},${config.position},${toString config.scale}";
        }
      ];
    }
  );
in {
  options.vicos.hyprland = {
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration to add to the Hyprland configuration file.";
    };

    monitors = mkOption {
      type = types.listOf hyprlandMonitor;
      description = "Hyprland monitor definitions.";
      default = [];
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
    vicos.hyprland = let
      primaryMonitor = lib.findFirst (m: m.primary) {} cfg.monitors;
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
        (lib.mkIf (primaryMonitor.scale or 1 > 1) {
          environmentVariables = {
            GDK_SCALE = builtins.toString (builtins.ceil primaryMonitor.scale);
            XCURSOR_SIZE = builtins.toString (builtins.ceil primaryMonitor.scale * 16);
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

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      greetd-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
    services.dbus.packages = [
      pkgs.gnome-keyring
      pkgs.gcr
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
    systemd.packages = [pkgs.waybar];
    systemd.user.services.waybar.wantedBy = ["default.target"];

    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        hyprlock # lock screem
        hyprpaper # wallpaper manager
        hyprpicker # color picker
        hyprshot # screenshot tool
        hyprcursor # cursor support
        rose-pine-hyprcursor # better default cursor
        ;
    };

    security.pam.services.swaylock = {};
    security.pam.services.hyprlock = {};

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
      monitorSpec = m:
        if m.disable
        then {
          output = m.output;
          disabled = true;
        }
        else {
          output = m.output;
          mode = m.mode;
          position = m.position;
          scale = m.scale;
        };
    in {
      hypr = {
        source = config.lib.vicos.stash "config/hypr";
        recursive = true;
      };

      waybar = {
        source = config.lib.vicos.stash "config/waybar";
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
            }
            // lib.optionalAttrs (cfg.primaryMonitor != "") {
              primary = cfg.primaryMonitor;
            };
        }}
      '';

      # "hypr/hyprland.pre.conf".text = ''
      #   $term = ${cfg.defaultTerminal}
      #   $browser = ${cfg.defaultBrowser}
      #   $editor = ${cfg.defaultEditor}
      #   $file = ${cfg.defaultFileManager}
      #
      #   ${lib.concatStringsSep "\n" (map (m: m.rawDefinition) cfg.monitors)}
      #   ${lib.optionalString (cfg.primaryMonitor != "") ''
      #     $monitor.primary = ${cfg.primaryMonitor}
      #   ''}
      # '';
    };
  };
}
