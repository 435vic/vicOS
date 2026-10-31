{
  config,
  lib,
  pkgs,
  nixCats,
  ...
}:
let
  cfg = config.vicos;
in
{
  options.vicos.neovim.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.callPackage ../packages/neovim { inherit nixCats; };
    description = "Personal Neovim bundle; extend with overrideNixCats using its existing package set.";
  };

  config = lib.mkIf (cfg.cli.enable && cfg.user != null) {
    users.users.${cfg.user}.packages = [ cfg.neovim.package ];

    stash.users.${cfg.user}.files.".config/nvim" = {
      source = config.lib.stash.fromStash {
        stash = "vicos";
        path = "config/nvim";
      };
      recursive = true;
    };

    environment.shellInit = ''
      if [ "$USER" = ${lib.escapeShellArg cfg.user} ]; then
        export EDITOR=${lib.getExe cfg.neovim.package}
        export VISUAL="$EDITOR"
      fi
    '';
  };
}
