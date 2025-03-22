nixCats@{utils, ...}: let
  luaPath = ../config/nvim;
  theming = import ./themes.nix;

  categoryDefinitions = {pkgs, categories, ...}: let
    themes = theming pkgs;
    mainTheme = themes.pkgFor (categories.colorscheme or "rose-pine");
    otherThemes = with pkgs.lib; pipe themes.definitions [
      (pkgs.lib.mapAttrsToList (_: def: def.package))
      (pkgs.lib.filter (pkg: pkg.pname != mainTheme.pname))
    ];
  in {
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
      general = with pkgs.vimPlugins; [
        lze # lazy loader
        oil-nvim # file explorer
        vim-sleuth # autodetect tab width, etc
        vim-fugitive # git integration
      ];

      themer = mainTheme;
    };

    optionalPlugins = {
      general = {
        treesitter = with pkgs.vimPlugins; [
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
        ];

        telescope = with pkgs.vimPlugins; [
          telescope-nvim
          telescope-fzf-native-nvim
        ];
      };

      extraThemes = otherThemes;
    };
  };

  packageDefinitions = let
    categoriesFull = pkgs: {
      general = true;
      nixdev = true;
      extraThemes = true;
      themer = true;
      colorscheme = "rose-pine";

      themeIndex = (theming pkgs).index;
    };
  in {
    # vico's vim :o
    vvim = {pkgs, ...}: {
      settings = {
      	aliases = [ "vim" "nvim" ];
        wrapRc = true;
      };

      categories = categoriesFull pkgs;
    };

    vvimpure = {pkgs, ...}: {
      settings = {
        aliases = [ "vim" "nvim" ];
        wrapRc = false;
      };

      categories = categoriesFull pkgs;
    };
  };
in {
  inherit luaPath categoryDefinitions packageDefinitions;
  default = "vvim";
  builder = nixpkgs: system: utils.baseBuilder luaPath {
    inherit nixpkgs system;
  } categoryDefinitions packageDefinitions;
}
