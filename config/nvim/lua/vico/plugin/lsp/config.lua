-- LSP config

return {
  {
    "lua_ls",
    enable = nixCats('ide.lsp'),
    lsp = {
      filetypes = { 'lua' }, 
    },
  },
}
