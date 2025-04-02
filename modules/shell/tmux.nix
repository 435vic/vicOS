{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.vicos.shell.tmux;
in {
  options.vicos.shell.tmux = {
    enable = mkEnableOption "tmux";
    plugins = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = "List of tmux plugins to install.";
      example = lib.literalExpression "[ pkgs.tmuxPlugins.nord ]";
    };
  };

  config = mkIf cfg.enable {
    environment.variables.TMUX_HOME = "$XDG_CONFIG_HOME/tmux";

    vicos.user.packages = [ pkgs.unstable.tmux ];

    environment.etc."tmux.conf".text = ''
      source-file $TMUX_HOME/tmux.conf

      ${lib.optionalString (cfg.plugins != [ ]) ''
        ${lib.concatMapStringsSep "\n" (plugin: "run-shell ${plugin.rtp}") cfg.plugins}
      ''}
    '';

    vicos.shell.tmux.plugins = with pkgs.tmuxPlugins; [
      yank
      rose-pine
    ];

    home.configFile.tmux = {
      source = config.lib.vicos.dirFromConfig "tmux";
      recursive = true;
    };
  };
}
