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
    },
  },
  {
    "hls",
    lsp = {
      filetypes = { "haskell" },
    },
  },
}
