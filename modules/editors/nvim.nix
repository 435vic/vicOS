{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.vicos.editors.nvim;
in {
  options.vicos.editors.nvim = {
    alias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to alias vim to nvim.";
    };
  };

  config = mkMerge [
    {
      environment.systemPackages = [
        pkgs.neovim
      ];

      home.configFile.nvim = {
        source = config.lib.vicos.dirFromConfig "nvim";
        recursive = true;
      };
    }
    (mkIf cfg.alias {
      environment.shellAliases = {
        vim = "nvim";
      };

      vicos.shell.fish.aliases.vim = "nvim";
    })
  ];
}