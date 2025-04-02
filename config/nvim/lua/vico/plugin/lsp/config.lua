-- LSP config

return {
  {
    "lua_ls",
    lsp = {
      filetypes = { 'lua' },
      config = {
        Lua = {
          workspace = {
            ignoreDir = { ".direnv", ".git" },
          },
        },
      },
    },
  },
  {
    "nil_ls",
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "ts_ls",
    lsp = {},
  },
  {
    "nixd",
    lsp = {
      filetypes = { "nix" },
      settings = {
        nixd = {
          nixpkgs = {
            expr =[[import <nixpkgs> {}]]
          },
          options = {
            nixos = {
              expr = [[(builtins.getFlake (builtins.getEnv DOTFILES_HOME)).nixosConfigurations.thunkbox.options]]
            },
          },
        }
      },
    },
  },
  {
    "hls",
    lsp = {
      filetypes = { "haskell" },
    },
  },
  {
    "jdtls",
    lsp = {
      filetypes = { "java" },
    },
  },
}
