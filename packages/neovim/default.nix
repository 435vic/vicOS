{ pkgs, nixCats }:
let
  categoryDefinitions =
    { pkgs, ... }:
    {
      lspsAndRuntimeDeps.editor = with pkgs; [
        ripgrep
        fd
        vscode-langservers-extracted
        lua-language-server
        nixd
        tinymist
        yaml-language-server
        prettierd
        emmet-language-server
      ];

      startupPlugins.editor = with pkgs.vimPlugins; [
        lze
        rose-pine
        oil-nvim
        vim-sleuth
        vim-fugitive
        direnv-vim
        nvim-lspconfig
        nvim-treesitter-textobjects
        (nvim-treesitter.withPlugins (
          p: with p; [
            javascript
            typescript
            tsx
            html
            css
            json
            yaml
            python
            lua
            bash
            rust
            c
            cpp
            haskell
            terraform
            hcl
            nix
            markdown
            markdown_inline
            typst
            toml
            dockerfile
            gitignore
            git_config
            git_rebase
            java
            regex
            comment
            diff
            query
            vim
            vimdoc
          ]
        ))
      ];

      optionalPlugins.editor = with pkgs.vimPlugins; [
        telescope-nvim
        conform-nvim
        blink-cmp
        lazydev-nvim
        nvim-jdtls
        typst-preview-nvim
        markdown-preview-nvim
        lualine-nvim
        which-key-nvim
      ];
    };

  packageDefinitions.vvim = _: {
    settings = {
      aliases = [
        "nvim"
        "vim"
      ];
      wrapRc = false;
    };
    categories.editor = true;
  };
in
nixCats.utils.baseBuilder ../../config/nvim {
  inherit pkgs;
} categoryDefinitions packageDefinitions "vvim"
