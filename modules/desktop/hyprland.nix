{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.vicos.hyprland;

  mkOpt =
    type: description:
    mkOption {
      inherit type description;
    };
  mkOpt' =
    type: description: default:
    mkOption {
      inherit type description default;
    };
  hyprlandMonitor = types.submodule (
    { config, ... }:
    {
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
            if config.disable then
              "monitor = ${config.output},disable"
            else
              "monitor = ${config.output},${config.mode},${config.position},${toString config.scale}";
        }
      ];
    }
  );
in
{
  options.vicos.hyprland = {
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration to add to the Hyprland configuration file.";
    };

    monitors = mkOption {
      type = types.listOf hyprlandMonitor;
      description = "Hyprland monitor definitions.";
      default = [ ];
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

    environmentVariables = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "Environment variables to set in ~/.config/uwsm/env-hyprland.";
    };
  };

  config = {
    vicos.desktop.wayland.enable = true;
    vicos.hyprland =
      let
        primaryMonitor = lib.findFirst (m: m.primary) { } cfg.monitors;
      in
      lib.mkMerge [
        {
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
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    programs.waybar.enable = true;
    systemd.packages = [ pkgs.waybar ];
    systemd.user.services.waybar.wantedBy = [ "default.target" ];

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        hyprlock # lock screem
        hyprpaper # wallpaper manager
        hyprpicker # color picker
        hyprshot # screenshot tool
        hyprcursor # cursor support
        rose-pine-hyprcursor # better default cursor
        ;
    };

    security.pam.services.swaylock = { };
    security.pam.services.hyprlock = { };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time";
          user = "greeter";
        };

        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "vico";
        };
      };
    };

    home.configFile = {
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

      "hypr/hyprland.pre.conf".text = ''
        $term = ${cfg.defaultTerminal}
        $browser = ${cfg.defaultBrowser}
        $editor = ${cfg.defaultEditor}

        ${lib.concatStringsSep "\n" (map (m: m.rawDefinition) cfg.monitors)}
        ${lib.optionalString (cfg.primaryMonitor != "") ''
          $monitor.primary = ${cfg.primaryMonitor}
        ''}
      '';
    };
  };
}
