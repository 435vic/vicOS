{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.dev.nvim;
  vvimVersion = if cfg.pure then "vvim" else "vvimpure";
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
      config.vicos.flake.packages.${vvimVersion}
    ];

    home.configFile.nvim = {
      # symlink the whole directory, as nix configuration
      # can be directly referenced in Lua thanks to nixcats
      source = config.lib.vicos.fileFromConfig "nvim";
    };
  };
}
