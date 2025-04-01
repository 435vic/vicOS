{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.vicos.shell.tmux;
in {
  options.vicos.shell.tmux.enable = mkEnableOption "tmux";

  config = mkIf cfg.enable {
    environment.variables.TMUX_HOME = "$XDG_CONFIG_HOME/tmux";

    vicos.user.packages = [ pkgs.unstable.tmux ];

    environment.etc."tmux.conf".text = with pkgs.tmuxPlugins; ''
      source-file $TMUX_HOME/tmux.conf

      run-shell ${yank.rtp}
    '';

    home.configFile.tmux = {
      source = config.lib.vicos.dirFromConfig "tmux";
      recursive = true;
    };
  };
}
