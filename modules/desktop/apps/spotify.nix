{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.apps.spotify;
  spicetify = config.vicos.flake.inputs.spicetify-nix;
  spicePkgs = spicetify.legacyPackages.${pkgs.stdenv.system};
in {
  options.vicos.desktop.apps.spotify = {
    enable = mkEnableOption "spotify with spicetify";
  };

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.dribbblish;
      colorScheme = "rosepine";
    };
  };
}
