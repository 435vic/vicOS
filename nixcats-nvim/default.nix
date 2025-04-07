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
    localPkgs = pkgs.callPackage ./packages.nix {};
  in {
    lspsAndRuntimeDeps = {
      general = with pkgs; [
        universal-ctags
        ripgrep
        fd
      ];

      ide = {
        lsp = with pkgs; [
          lua-language-server
          nixd
          nil
          nix-doc
        ];
      };
    };

    startupPlugins = {
      # TODO: add theme support
      general = with pkgs.vimPlugins; [
        lze # lazy loader
        lzextras # lazy load lsp configs
        oil-nvim # file explorer
        vim-sleuth # autodetect tab width, etc
        vim-fugitive # git integration
        direnv-vim # direnv integration
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

      training = with pkgs.vimPlugins; [
        localPkgs.vim-be-good
        which-key-nvim
      ];

      ide = {
        cmp = with pkgs.vimPlugins; [
          blink-cmp
          luasnip
        ];

        lsp = with pkgs.vimPlugins; [
          nvim-lspconfig
          lazydev-nvim
          typescript-tools-nvim
          nvim-jdtls
        ];

        extra = with pkgs.vimPlugins; [
          lualine-nvim
        ];
      };

      misc = with pkgs.vimPlugins; [
        obsidian-nvim
        markdown-preview-nvim
        presence-nvim
      ];

      extraThemes = otherThemes;
    };
  };

  packageDefinitions = let
    baseCategories = {
      general = true;
      themer = true;
      colorscheme = "rose-pine";
    };

    fullCategories = baseCategories // {
      ide = true;
      training = true;
      extraThemes = true;
      misc = true;
    };

    themeData = pkgs: { themeIndex = (theming pkgs).index; };
  in {
    # vico's vim :o
    vvim = {pkgs, ...}: {
      settings = {
      	aliases = [ "vim" "nvim" ];
        wrapRc = true;
      };
      categories = fullCategories // themeData pkgs;
    };
  };
in {
  inherit luaPath categoryDefinitions packageDefinitions;
  default = "vvim";
  builder = nixpkgs: system: utils.baseBuilder luaPath {
    inherit nixpkgs system;
  } categoryDefinitions packageDefinitions;
}
