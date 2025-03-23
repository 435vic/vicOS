{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.dev.nvim;
  flakePkgs = config.vicos.flake.packages;
  nvim = if cfg.pure then flakePkgs.vvim else flakePkgs.vvim.impure;
in {
  options.vicos.dev.nvim = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable neovim";
      default = true;
    };

    pure = mkOption {
      type = types.bool;
      description = "Whether to enable pure mode (use config in /nix/store)";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      nvim
    ];

    home.configFile.nvim = mkIf (not cfg.pure) {
      # symlink the whole directory, as nix configuration
      # can be directly referenced in Lua thanks to nixcats
      source = config.lib.vicos.fileFromConfig "nvim";
    };
  };
}
