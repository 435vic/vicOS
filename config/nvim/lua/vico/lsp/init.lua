
local function lsp_on_attach(_, bufid)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufid, desc = desc })
  end

  nmap('gd', '<CMD>Telescope lsp_definitions<CR>', 'Goto Definition')
  nmap('gD', '<CMD>Telescope lsp_declarations<CR>', 'Goto Declaration')
  nmap('gi', '<CMD>Telescope lsp_implementations<CR>', 'Goto implementation')
  nmap('gr', '<CMD>Telescope lsp_references<CR>', 'Goto Reference(s)')
  nmap('<F2>', vim.lsp.buf.rename, 'Rename Symbol')
  nmap('<leader>ff', vim.lsp.buf.format, 'Format Document')
end

-- For all LSPs, .git guarantees that the folder is
-- a project
vim.lsp.config('*', {
  root_markers = {'.git'},
});

vim.lsp.enable({
  'lua_ls',
  'nixd',
  'hls'
});

return {
  {
    "nvim-lspconfig",
    on_require = { "lspconfig" },
  },
  {
    "typescript-tools.nvim",
    ft = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    after = function(_)
      require("lspconfig")
      require('typescript-tools').setup({})
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
  {
    "nvim-jdtls",
    ft = "java",
    after = function(_)
      require('jdtls').start_or_attach({
        cmd = { 'jdtls' },
        root_dir = vim.fs.dirname(vim.fs.find({'pom.xml', 'config.gradle', '.git'}, { upward = true })[1]),
      })
    end,
  },
}
