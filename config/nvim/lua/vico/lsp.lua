--- @type lze.Spec
return {
  {
    "nvim-lspconfig",
    event = { "DeferredUIEnter" },
    on_require = { 'lspconfig' },
    after = function(_)
      vim.lsp.config('*', {
        root_markers = {'.git'},
      });

      vim.lsp.config('jsonls', {
        cmd = { "vscode-json-languageserver", "--stdio" },
        settings = {
          json = {
            schemas = {
              {
                fileMatch = { "package.json" },
                url = "https://json.schemastore.org/package.json"
              },
              {
                fileMatch = { "tsconfig*.json" },
                url = "https://json.schemastore.org/tsconfig.json"
              },
              {
                fileMatch = {
                  ".prettierrc",
                  ".prettierrc.json",
                  "prettier.config.json"
                },
                url = "https://json.schemastore.org/prettierrc.json"
              },
              {
                fileMatch = { ".eslintrc", ".eslintrc.json" },
                url = "https://json.schemastore.org/eslintrc.json"
              },
              {
                fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                url = "https://json.schemastore.org/babelrc.json"
              },
              {
                fileMatch = { "lerna.json" },
                url = "https://json.schemastore.org/lerna.json"
              },
              {
                fileMatch = { "now.json", "vercel.json" },
                url = "https://json.schemastore.org/now.json"
              },
              {
                fileMatch = {
                  ".stylelintrc",
                  ".stylelintrc.json",
                  "stylelint.config.json"
                },
                url = "http://json.schemastore.org/stylelintrc.json"
              }
            }
          },
        },
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
