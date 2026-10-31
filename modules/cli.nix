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
  options.vicos.cli.enable = lib.mkEnableOption "the common personal CLI environment";

  config = lib.mkIf cfg.cli.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.user != null;
            message = "vicos.cli.enable requires vicos.user to name an existing normal user.";
          }
        ];
      }
      (lib.mkIf (cfg.user != null) {
        assertions = [
          {
            assertion = config.users.users.${cfg.user}.isNormalUser;
            message = "vicOS does not create accounts: declare vicos.user as a normal user in the fleet configuration.";
          }
        ];

        users.users.${cfg.user}.packages = with pkgs; [
          bat
          btop
          curl
          delta
          eza
          fd
          file
          fzf
          ghostty.terminfo
          gitui
          jq
          less
          lsof
          ncdu
          nh
          nix-output-monitor
          nix-search-cli
          nix-tree
          p7zip
          ripgrep
          rsync
          tree
          unzip
          wget
          yq-go
          zip
          config.lib.stash.packages.stash-cli
        ];

        stash.users.${cfg.user}.stashes.vicos.path = cfg.dotfilesPath;
      })
    ]
  );
}
