nixCats@{utils, ...}: let
  luaPath = ./config/nvim;

  categoryDefinitions = {pkgs, ...}: {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        universal-ctags
        ripgrep
        fd
      ];

      nixdev = with pkgs; [
        nix-doc
        nixd
        nil
      ];
    };

    startupPlugins = {
      # TODO: add theme support
    };
  };

  baseCategories = {
    general = true;
    nixdev = true;
  };

  packageDefinitions = {
    # vico's vim :o
    vvim = {pkgs, ...}: {
      settings = {
      	aliases = [ "vim" "nvim" ];
        wrapRc = true;
      };

      categories = baseCategories;
    };
  };

in {
  inherit luaPath categoryDefinitions packageDefinitions;
  default = "vvim";
  builder = nixpkgs: system: utils.baseBuilder luaPath {
    inherit nixpkgs system;
  } categoryDefinitions packageDefinitions;
}
