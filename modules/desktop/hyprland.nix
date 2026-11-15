{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
in
{
  config = lib.mkIf cfg.desktop.enable (
    lib.mkMerge [
      {
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
          pkgs.rofi
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
      (lib.mkIf (cfg.user != null) {
        stash.users.${cfg.user}.files."${cfg.xdg.configHome}/hypr" = {
          source = config.lib.stash.fromStash {
            stash = "vicos";
            path = "config/hypr";
          };
          recursive = true;
        };

        systemd.packages = [
          pkgs.hyprpolkitagent
          pkgs.hyprpaper
          pkgs.mako
        ];
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
