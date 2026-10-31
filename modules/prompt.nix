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
  options.vicos.prompt = lib.mkOption {
    type = lib.types.enum [
      "gruvbox"
      "jetpack"
    ];
    default = "gruvbox";
    description = "Native Starship prompt configuration.";
  };

  config = lib.mkIf (cfg.cli.enable && cfg.user != null) {
    users.users.${cfg.user}.packages = [ pkgs.starship ];

    stash.users.${cfg.user}.files.".config/starship.toml".source = config.lib.stash.fromStash {
      stash = "vicos";
      path = "config/starship/${cfg.prompt}.toml";
    };
  };
}
