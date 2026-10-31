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
    programs.fish.enable = true;
    programs.fish.extraCompletionPackages = config.users.users.${cfg.user}.packages;

    users.users.${cfg.user}.packages = with pkgs; [
      direnv
      zoxide
    ];

    stash.users.${cfg.user}.files = {
      ".config/fish" = {
        source = config.lib.stash.fromStash {
          stash = "vicos";
          path = "config/fish";
        };
        recursive = true;
      };
      ".config/direnv/direnvrc".text = ''
        source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
      '';
    };
  };
}
