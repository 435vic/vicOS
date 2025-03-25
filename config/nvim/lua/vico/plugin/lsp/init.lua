
local function lsp_on_attach(_, bufid)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufid, desc = desc })
  end

  nmap('gd', '<CMD>Telescope lsp_definitions<CR>', 'Goto Definition')
  nmap('gD', '<CMD>Telescope lsp_declarations<CR>', 'Goto Declaration')
  nmap('gi', '<CMD>Telescope lsp_implementations<CR>', 'Goto implementation')
  nmap('gr', '<CMD>Telescope lsp_references<CR>', 'Goto Reference(s)')
  nmap('<F2>', vim.lsp.buf.rename, 'Rename Symbol')
end

return {
  {
    "nvim-lspconfig",
    on_require = { "lspconfig" },
    lsp = function(plugin)
      if (plugin.name == "ts_ls") then
        -- Typescript-tools is better, but is not in lspconfig
        require("typescript-tools").setup({})
        return
      end

      require("lspconfig")[plugin.name].setup(vim.tbl_extend("force", {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
        on_attach = lsp_on_attach,
      }, plugin.lsp or {}))
    end,
  },
  {
    "typescript-tools.nvim",
    on_require = { "typescript-tools" }
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
