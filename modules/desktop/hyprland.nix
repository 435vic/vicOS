{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  inherit (lib) mkOption types;

  monitor = types.submodule {
    freeformType = types.attrsOf types.anything;
    options = {
      output = mkOption {
        type = types.str;
        description = "Output name or selector, such as eDP-1 or desc:...";
      };
      mode = mkOption {
        type = types.str;
        default = "preferred";
      };
      position = mkOption {
        type = types.str;
        default = "auto";
      };
      scale = mkOption {
        type = types.oneOf [
          types.int
          types.float
          types.str
        ];
        default = 1;
      };
      disabled = mkOption {
        type = types.bool;
        default = false;
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Place workspaces on this monitor and derive GDK_SCALE and XCURSOR_SIZE from its scale.";
      };
      virtual = mkOption {
        type = types.bool;
        default = false;
        description = "Create this output as a Hyprland headless monitor at startup.";
      };
    };
  };

  primaryMonitor = lib.findFirst (m: m.primary) { scale = 1; } cfg.hyprland.monitors;
  primaryScale =
    if builtins.isString primaryMonitor.scale then 1 else builtins.ceil primaryMonitor.scale;
  # Dictation needs only CPU whisper; with nixpkgs rocmSupport it would pull
  # ~3 GiB of ROCm libraries and miss the binary cache.
  vicinae = pkgs.vicinae.override {
    whisper-cpp = pkgs.whisper-cpp.override { rocmSupport = false; };
  };
  scaleVariables = {
    GDK_SCALE = toString primaryScale;
    XCURSOR_SIZE = toString (primaryScale * 16);
  };
in
{
  options.vicos.hyprland.monitors = mkOption {
    type = types.listOf monitor;
    default = [ ];
    description = "Hyprland monitor definitions. Entries are passed to hl.monitor, so arbitrary HL.MonitorSpec fields may be added besides the documented ones.";
  };

  config = lib.mkIf cfg.desktop.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = builtins.all (
              m: m.virtual -> builtins.match "[A-Za-z0-9_-]+" m.output != null
            ) cfg.hyprland.monitors;
            message = ''
              vicos.hyprland.monitors: monitors with virtual = true are created as
              headless outputs, so output must be a plain name (e.g. "HEADLESS-1"),
              not a desc:/selector expression.
            '';
          }
        ];

        programs.hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
        };

        services.displayManager = {
          ly.enable = true;
          defaultSession = lib.mkDefault "hyprland-uwsm";
        };

        xdg.portal.config.hyprland.default = [
          "hyprland"
          "gtk"
        ];

        environment.systemPackages = [
          pkgs.wl-clipboard
          pkgs.hyprpaper
          vicinae
          pkgs.quickshell
          pkgs.mako
          pkgs.libnotify
          pkgs.pamixer
          pkgs.brightnessctl
          pkgs.playerctl
          pkgs.hyprshot
          pkgs.wiremix
          (pkgs.legcord.overrideAttrs (old: {
            # patchelf 0.15.2 corrupts venmic's .init/.plt when adding RPATHs.
            nativeBuildInputs = [ pkgs.patchelfUnstable ] ++ old.nativeBuildInputs;
          }))
        ];

        services.dbus.packages = [ pkgs.mako ];
      }
      (lib.mkIf (primaryScale > 1) {
        environment.sessionVariables = scaleVariables;
        environment.etc."environment.d/70-vicos-desktop.conf".text = lib.concatLines (
          lib.mapAttrsToList (name: value: "${name}=${value}") scaleVariables
        );
      })
      (lib.mkIf (cfg.user != null) {
        stash.users.${cfg.user}.files = {
          "${cfg.xdg.configHome}/hypr" = {
            source = config.lib.stash.fromStash {
              stash = "vicos";
              path = "config/hypr";
            };
            recursive = true;
          };

          "${cfg.xdg.configHome}/hypr/nixvars.lua".text =
            "return "
            + lib.generators.toLua { } {
              monitors = map (
                m:
                removeAttrs m [
                  "primary"
                  "virtual"
                ]
              ) cfg.hyprland.monitors;
              virtual = map (m: m.output) (builtins.filter (m: m.virtual) cfg.hyprland.monitors);
              primary = primaryMonitor.output or null;
            }
            + "\n";

          "${cfg.xdg.configHome}/quickshell" = {
            source = config.lib.stash.fromStash {
              stash = "vicos";
              path = "config/quickshell";
            };
            recursive = true;
          };
        };

        # Battery state for the Quickshell bar.
        services.upower.enable = true;

        systemd.packages = [
          pkgs.hyprpolkitagent
          pkgs.hyprpaper
          pkgs.mako
          vicinae
        ];
        systemd.user.services.vicinae = {
          unitConfig.ConditionUser = cfg.user;
          wantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.quickshell = {
          description = "Quickshell desktop shell";
          unitConfig.ConditionUser = cfg.user;
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = lib.getExe pkgs.quickshell;
            Restart = "on-failure";
          };
        };
        systemd.user.services.mako = {
          unitConfig.ConditionUser = cfg.user;
          wantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.hyprpaper = {
          unitConfig.ConditionUser = cfg.user;
          wantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.hyprpolkitagent = {
          unitConfig.ConditionUser = cfg.user;
          wantedBy = [ "graphical-session.target" ];
        };
      })
    ]
  );
}
