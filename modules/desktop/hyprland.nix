{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.hyprland;
  mkOpt = type: description: mkOption {
    inherit type description;
  };
  mkOpt' = type: description: default: mkOption {
    inherit type description default;
  };
  hyprlandMonitor = types.submodule ({config, ...}: {
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

    config = mkMerge [
      (mkIf (config.selector != "") {
        output = config.selector;
      })
      {
        rawDefinition = 
          if config.disable
          then "monitor = ${config.output},disable"
          else "monitor = ${config.output},${config.mode},${config.position},${toString config.scale}";
      }
    ];
  });
in {
  options.vicos.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
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
      default =
        if config.vicos.desktop.browser.zen.enable
        then "zen-beta"
        else "firefox";
      description = "Default browser to launch when inputting browser keybind.";
    };

    defaultTerminal = mkOption {
      type = types.str;
      default = "alacritty";
      description = "Default terminal to launch when inputting terminal keybind.";
    };

    environmentVariables = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "Environment variables to set in ~/.config/uwsm/env-hyprland.";
    };
  };

  config = mkIf cfg.enable {
    vicos.desktop.wayland.enable = true;
    vicos.desktop.hyprland = mkMerge [
      {
        environmentVariables = {
          XCURSOR_SIZE = "24";
          XCURSOR_THEME = mkDefault "Adwaita";
          GTK_THEME = mkDefault "Adwaita:dark";
          QT_STYLE_OVERRIDE = mkDefault "Adwaita-Dark";
          QT_QPA_PLATFORMTHEME = mkDefault "qt5ct";
        };
      }
      (let
        primaryMonitor = findFirst (m: m.primary) {} cfg.monitors;
      in mkIf (primaryMonitor ? output) {
        primaryMonitor = primaryMonitor.output;
      })
    ];

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # the newer versions of hyprland require recent mesa drivers
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    environment.systemPackages = with pkgs.unstable; [
      hyprlock # lock screem
      hyprpaper # wallpaper manager
      hyprpicker # color picker
      hyprshot # screenshot tool
      hyprcursor # cursors

      mako # notification daemon
      pamixer # volume control
      btop # process manager
    ];

    security.pam.services.swaylock = {};
    security.pam.services.hyprlock = {};

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = config.vicos.username;
      };
    };

    home.configFile = {
      hypr = {
        source = config.lib.vicos.dirFromConfig "hypr";
        recursive = true;
      };

      "uwsm/env-hyprland".text = pipe cfg.environmentVariables [
        (mapAttrsToList (n: v: "export ${escapeShellArg n}=${escapeShellArg v}"))
        concatLines
      ];

      mako = {
        source = config.lib.vicos.dirFromConfig "mako";
        recursive = true;
      };

      "hypr/hyprland.pre.conf".text = let
      in ''
        $term = ${cfg.defaultTerminal}
        $browser = ${cfg.defaultBrowser}
        $editor = ${cfg.defaultEditor}

        ${concatStringsSep "\n" (map (m: m.rawDefinition) cfg.monitors)}
        ${optionalString (cfg.primaryMonitor != "") '' 
          $monitor.primary = ${cfg.primaryMonitor}
        ''} 
        exec-once = hyprlock --immediate
      '';

      "hypr/hyprland.post.conf".text = cfg.extraConfig;
    };
  };
}
