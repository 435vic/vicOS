{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.editors.nvim;
in {
  options.vicos.editors.nvim = {
    pure = mkOption {
      type = types.bool;
      description = "Whether to enable pure mode (use config in /nix/store)";
      default = true;
    };
  };

  config.vvim = {
    enable = true;
    packageDefinitions.replace = {
      nixCats = {...}: {
        settings = {
          wrapRc = cfg.pure;
        };
      };
    };
  };
}
