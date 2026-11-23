{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  hyprctl = lib.getExe' config.programs.hyprland.package "hyprctl";
  loginctl = lib.getExe' pkgs.systemd "loginctl";
in
{
  options.vicos.desktop.idle.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Automatically lock after five minutes and turn displays off after five and a half. Manual and pre-suspend locking remain available when disabled.";
  };

  config = lib.mkIf (cfg.desktop.enable && cfg.user != null) {
    services.hypridle.enable = true;
    systemd.user.services.hypridle.unitConfig.ConditionUser = cfg.user;

    stash.users.${cfg.user}.files."${cfg.xdg.configHome}/hypr/hypridle.conf".text = ''
      general {
          lock_cmd = ${lib.getExe cfg.desktop.pond.lock}
          before_sleep_cmd = ${loginctl} lock-session
          after_sleep_cmd = ${hyprctl} dispatch 'hl.dsp.dpms({action = "on"})'
          inhibit_sleep = 3
      }
    ''
    + lib.optionalString cfg.desktop.idle.enable ''

      listener {
          timeout = 300
          on-timeout = ${loginctl} lock-session
      }

      listener {
          timeout = 330
          on-timeout = ${hyprctl} dispatch 'hl.dsp.dpms({action = "off"})'
          on-resume = ${hyprctl} dispatch 'hl.dsp.dpms({action = "on"})'
      }
    '';
  };
}
