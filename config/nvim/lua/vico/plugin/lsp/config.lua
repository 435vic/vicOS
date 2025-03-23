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
    "nixd",
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "hls",
    lsp = {
      filetypes = { "haskell" },
    },
  },
}
