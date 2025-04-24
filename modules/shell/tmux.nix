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
    sesh = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
    plugins = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = "List of tmux plugins to install.";
      example = lib.literalExpression "[ pkgs.tmuxPlugins.nord ]";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
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
    }
    (mkIf cfg.sesh.enable {
      vicos.user.packages = [ pkgs.unstable.sesh ];
      programs.fish.interactiveShellInit = mkAfter ''
        bind ctrl-f 'sesh connect (sesh list | fzf)'
        bind -M insert ctrl-f 'sesh connect (sesh list | fzf)'
      '';
      environment.etc."tmux.conf".text = mkAfter ''
        bind-key "C-f" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""
      '';
    })
  ]);
}
