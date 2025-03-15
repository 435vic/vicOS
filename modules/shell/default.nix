{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.shell;
in
{
  imports = [
    ./git.nix
  ];

  options = {
    vicos.shell.fish.runByDefault = mkOption {
      type = types.bool;
      default = false;
      description = "Run fish as default interactive shell (but not login shell)";
    };

    vicos.shell.starship.enable = mkEnableOption "starship prompt";
  };

  config = mkMerge [
    {
      # for better scripting
      programs.fish = {
        enable = true;
        # fish 4.0
        package = pkgs.unstable.fish;
      };

      home.configFile.fish = {
        source = config.lib.vicos.dirFromConfig "fish";
        recursive = true;
      };
    }
    (mkIf cfg.fish.runByDefault {
      # We do this instead of setting fish as the login shell because it's not POSIX compliant
      # see https://fishshell.com/docs/current/index.html#default-shell
      programs.bash.interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    })
    (mkIf cfg.starship.enable {
      home.configFile."fish/config.post.fish".text = mkAfter ''
        starship init fish | source
      '';

      home.configFile."starship.toml".source = config.lib.vicos.fileFromConfig "starship.toml";
    })
  ];
}
