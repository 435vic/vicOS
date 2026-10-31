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
  config = lib.mkIf (cfg.cli.enable && cfg.user != null) {
    users.users.${cfg.user}.packages = [ pkgs.git ];

    stash.users.${cfg.user}.files.".config/git" = {
      source = config.lib.stash.fromStash {
        stash = "vicos";
        path = "config/git";
      };
      recursive = true;
    };
  };
}
