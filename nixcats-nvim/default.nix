nixCats@{ utils, ... }:
let
  luaPath = ../config/nvim;
  theming = import ./themes.nix;

  categoryDefinitions =
    {
      pkgs,
      categories,
      ...
    }:
    let
      themes = theming pkgs;
      mainTheme = themes.pkgFor (categories.colorscheme or "rose-pine");
      otherThemes =
        with pkgs.lib;
        pipe themes.definitions [
          (pkgs.lib.mapAttrsToList (_: def: def.package))
          (pkgs.lib.filter (pkg: pkg.pname != mainTheme.pname))
        ];
      localPkgs = pkgs.callPackage ./packages.nix { };
    in
    {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
          vscode-langservers-extracted
        ];

        ide = {
          # most of the time we leave the language server installation
          # up to the project specific flake, but some languages are so often used
          # or often present in flakeless setups that it's worth to bundle them
          # with the editor
          lsp = with pkgs; [
            lua-language-server
            nixd
            nil
            nix-doc
            tinymist
            yaml-language-server
            prettierd
            emmet-language-server
          ];
        };

        ai = with pkgs; [
          nodejs_22
        ];
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
            (nvim-treesitter.withPlugins (p: [
              # Web development
              p.javascript
              p.typescript
              p.tsx
              p.html
              p.css
              p.json
              p.yaml

              # Systems/scripting
              p.python
              p.lua
              p.bash
              p.rust
              p.c
              p.cpp

              p.haskell
              p.terraform
              p.hcl

              # Nix ecosystem
              p.nix

              # Markup/docs
              p.markdown
              p.markdown_inline
              p.typst

              # Config files
              p.toml
              p.dockerfile
              p.gitignore
              p.git_config
              p.git_rebase

              # Java (you have ftplugin for it)
              p.java

              # Misc useful
              p.regex
              p.comment
              p.diff
              p.query # for treesitter queries
              p.vim
              p.vimdoc
            ]))
          ];

          telescope = with pkgs.vimPlugins; [
            telescope-nvim
            telescope-fzf-native-nvim
          ];

          general = with pkgs.vimPlugins; [
            conform-nvim
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
            typst-preview-nvim
            vim-mustache-handlebars
          ];

          extra = with pkgs.vimPlugins; [
            lualine-nvim
          ];
        };

        ai = {
          copilot = with pkgs.vimPlugins; [
            copilot-vim
            CopilotChat-nvim
          ];
        };

        misc = with pkgs.vimPlugins; [
          obsidian-nvim
          markdown-preview-nvim
          presence-nvim
          localPkgs.golf-vim
        ];

        extraThemes = otherThemes;
      };
    };

  packageDefinitions =
    let
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

      # added so that you don't need to allow unfree packages on nix run vicOS#vvim
      unfreeCategories = {
        ai = true;
      };

      themeData = pkgs: { themeIndex = (theming pkgs).index; };
    in
    {
      vvim-minimal =
        { pkgs, ... }:
        {
          settings = {
            aliases = [
              "vim"
              "nvim"
            ];
            wrapRc = true;
          };

          categories = baseCategories;
        };

      # vico's vim :o
      vvim =
        { pkgs, ... }:
        {
          settings = {
            aliases = [
              "vim"
              "nvim"
            ];
            wrapRc = true;
          };
          categories = fullCategories // themeData pkgs;
        };

      vvim-wsl =
        { pkgs, ... }:
        {
          settings = {
            aliases = [
              "vim"
              "nvim"
            ];
            wrapRc = true;
          };
          categories =
            fullCategories
            // themeData pkgs
            // {
              wsl = true;
            };
        };

      vvim-unfree =
        { pkgs, ... }:
        {
          settings = {
            aliases = [
              "vim"
              "nvim"
            ];
            wrapRc = true;
          };

          categories = fullCategories // unfreeCategories // themeData pkgs;
        };
    };
in
rec {
  inherit luaPath categoryDefinitions packageDefinitions;
  default = "vvim";
  builder =
    nixpkgs: system:
    utils.baseBuilder luaPath {
      inherit nixpkgs system;
      extra_pkg_config = {
        allowUnfree = true;
      };
    } categoryDefinitions packageDefinitions;
  mkNvimPackages =
    {
      nixpkgs,
      system,
    }:
    let
      inherit (nixCat.utils) mergeCatDefs;
      impureOverride =
        { ... }:
        {
          settings.wrapRc = false;
        };
      nixCat = builder nixpkgs system default;
      mkCat =
        name: def:
        (nixCat.override { inherit name; })
        // {
          impure = nixCat.override {
            inherit name;
            packageDefinitions.${name} = mergeCatDefs nixCat.packageDefinitions.${name} impureOverride;
          };
        };
    in
    nixpkgs.lib.mapAttrs mkCat nixCat.packageDefinitions;
}
