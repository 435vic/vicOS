{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.dev.nvim;
  flakePkgs = config.vicos.flake.packages;
  nvim =
    if cfg.pure
    then flakePkgs.vvim-unfree
    else flakePkgs.vvim-unfree.impure;
in {
  options.vicos.dev.nvim = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable neovim";
      default = true;
    };

    package = mkOption {
      type = types.package;
      description = "neovim package to use";
      default = nvim;
    };

    pure = mkOption {
      type = types.bool;
      description = "Whether to enable pure mode (use config in /nix/store)";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    environment.variables.EDITOR = "nvim";

    home.configFile.nvim = mkIf (!cfg.pure) {
      # symlink the whole directory, as nix configuration
      # can be directly referenced in Lua thanks to nixcats
      source = config.lib.vicos.fileFromConfig "nvim";
    };
  };
}
