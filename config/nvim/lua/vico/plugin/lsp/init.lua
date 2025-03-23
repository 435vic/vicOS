
local function lsp_on_attach()

end

return {
  {
    "nvim-lspconfig",
    on_require = { "lspconfig" },
    lsp = function(plugin)
      require("lspconfig")[plugin.name].setup(vim.tbl_extend("force", {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
        on_attach = lsp_on_attach,
      }, plugin.lsp or {}))
    end,
  },
  {
    "lazydev.nvim",
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  { import = "vico.plugin.lsp.config" },
}
