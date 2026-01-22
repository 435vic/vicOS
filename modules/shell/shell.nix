{ config, lib, ... }:
let
  inherit (lib) types;
  cfg = config.vicos;
in
{
  options.vicos = {
    git = {
      name = lib.mkOption {
        type = types.nullOr types.str;
        description = "User's Git name";
        default = null;
      };

      email = lib.mkOption {
        type = types.nullOr types.str;
        description = "User's Git email";
        default = null;
      };
    };
  };

  config = {
    programs.git.config = {
      init.defaultBranch = "main";
      push.autoSetupRemote = "true";
      url."https://github.com".insteadOf = [
        "gh:"
        "github:"
      ];
    };

    environment.sessionVariables = {
      EDITOR = "nvim";
    };

    home.configFile."git/config" = {
      enable = cfg.git.name != null && cfg.git.email != null;
      text = lib.optionalString (cfg.git.name != null && cfg.git.email != null) ''
        [user]
          name = ${cfg.git.name}
          email = ${cfg.git.email}
      '';
    };

    home.configFile."git/ignore".source = config.lib.vicos.stash "config/git/ignore";
    home.configFile."starship.toml".source = config.lib.vicos.stash "config/starship.toml";
    home.configFile."starship-jetpack.toml".source =
      config.lib.vicos.stash "config/starship-jetpack.toml";
    home.file.".ssh/config".source = config.lib.vicos.stash "config/ssh/config";
  };
}
