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
        ];
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
        ];
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
