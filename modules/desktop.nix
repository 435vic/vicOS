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
  options.vicos.desktop = {
    enable = lib.mkEnableOption "the personal desktop applications and preferences";

    apps.terminal = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            description = "Package providing the default terminal emulator.";
          };
          desktop = lib.mkOption {
            type = lib.types.str;
            description = "Desktop entry ID of the default terminal emulator.";
          };
        };
      };
      default = {
        package = pkgs.ghostty;
        desktop = "com.mitchellh.ghostty.desktop";
      };
      description = "Default terminal used for installation and desktop launchers.";
    };
  };

  config = lib.mkIf cfg.desktop.enable (
    lib.mkMerge [
      {
        vicos.cli.enable = true;
        environment.sessionVariables.XCOMPOSECACHE = "$HOME/${cfg.xdg.cacheHome}/xcompose";
        environment.etc."environment.d/70-vicos-desktop.conf".text = ''
          XCOMPOSECACHE=$HOME/${cfg.xdg.cacheHome}/xcompose
        '';
        systemd.user.tmpfiles.rules = [
          ''d "%h/${cfg.xdg.cacheHome}/xcompose" :0700 - - -''
        ];
      }
      (lib.mkIf (cfg.user != null) {
        users.users.${cfg.user}.packages = [
          cfg.desktop.apps.terminal.package
          pkgs.xdg-terminal-exec
        ];

        stash.users.${cfg.user}.files."${cfg.xdg.configHome}/xdg-terminals.list".text =
          "${cfg.desktop.apps.terminal.desktop}\n";
      })
    ]
  );
}
