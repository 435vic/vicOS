return {
  {
    "nvim-lspconfig",
    event = { "DeferredUIEnter" },
    after = function(_)
      vim.lsp.config('*', {
        root_markers = {'.git'},
      });

      vim.lsp.config('jsonls', {
        cmd = { "vscode-json-languageserver", "--stdio" }
      })

      vim.lsp.enable({
        'lua_ls',
        'nixd',
        'nil',
        'hls',
        'jsonls',
        'tinymist'
      });
    end,
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
    on_require = { "jdtls" }
  }
}
