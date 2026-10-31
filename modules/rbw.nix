{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  rbw = pkgs.callPackage ../packages/rbw { };
in
{
  options.vicos.rbw = {
    enable = lib.mkEnableOption "the personal Bitwarden CLI and SSH agent";

    email = lib.mkOption {
      type = lib.types.str;
      description = "Bitwarden account email address.";
    };

    url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Bitwarden server URL; null uses the official service.";
    };
  };

  config = lib.mkIf cfg.rbw.enable (
    lib.mkMerge [
      { vicos.cli.enable = true; }
      (lib.mkIf (cfg.user != null) {
        users.users.${cfg.user}.packages = [ rbw ];
        services.dbus.packages = [ pkgs.gcr ];

        stash.users.${cfg.user}.files.".config/rbw/config.json".text = builtins.toJSON {
          inherit (cfg.rbw) email;
          base_url = cfg.rbw.url;
          pinentry = lib.getExe pkgs.pinentry-gnome3;
        };

        environment.extraInit = ''
          if [ "$USER" = ${lib.escapeShellArg cfg.user} ] &&
             [ -n "''${XDG_RUNTIME_DIR-}" ] && [ -z "''${SSH_AUTH_SOCK+x}" ]; then
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
          fi
        '';

        systemd.user.services.rbw-agent = {
          description = "Bitwarden CLI and SSH agent";
          unitConfig.ConditionUser = cfg.user;
          serviceConfig = {
            ExecStart = "${rbw}/bin/rbw-agent --no-daemonize";
            Restart = "on-failure";
          };
          wantedBy = [ "default.target" ];
        };
      })
    ]
  );
}
