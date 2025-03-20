{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.browser;
in {
  options.vicos.desktop.browser = {
    enable = mkEnableOption "web browser";
    zen = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use the Zen browser instead of firefox, transferring all configs.";
      };
      package = mkOption {
        type = types.package;
        default = config.lib.flake.getInput "zen-browser" "packages" "default";
        description = "The Zen browser package to use.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (!cfg.zen.enable) {
      programs.firefox = {
        enable = true;
        package = pkgs.unstable.firefox;
      };
    })
    (mkIf cfg.zen.enable {
      environment.systemPackages = [cfg.zen.package];
    })
  ]);
}
