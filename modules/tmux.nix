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
    users.users.${cfg.user}.packages = with pkgs; [
      tmux
      sesh
    ];

    stash.users.${cfg.user}.files = {
      ".config/tmux/tmux.conf".source = config.lib.stash.fromStash {
        stash = "vicos";
        path = "config/tmux/tmux.conf";
      };
      ".config/sesh/sesh.toml".source = config.lib.stash.fromStash {
        stash = "vicos";
        path = "config/sesh/sesh.toml";
      };
    };
  };
}
