--
-- ▗▞▀▘ ▄▄▄  █  ▄▄▄   ▄▄▄ ▄▄▄ ▗▞▀▘▐▌   ▗▞▀▚▖▄▄▄▄  ▗▞▀▚▖ ▄▄▄
-- ▝▚▄▖█   █ █ █   █ █   ▀▄▄  ▝▚▄▖▐▌   ▐▛▀▀▘█ █ █ ▐▛▀▀▘▀▄▄
--     ▀▄▄▄▀ █ ▀▄▄▄▀ █   ▄▄▄▀     ▐▛▀▚▖▝▚▄▄▖█   █ ▝▚▄▄▖▄▄▄▀
--           █                    ▐▌ ▐▌
--
-- The default colorscheme is loaded on startup
local colorscheme = nixCats("colorscheme")
vim.cmd.colorscheme(colorscheme)

-- Register extra plugins to be lazy loaded if enabled
if nixCats("extraThemes") then
  require("lze").load("vico.plugin.colorschemes")
end

-- todo: cool ascii title
-- oil

-- disable netrw loading
vim.g.loaded_netRwPlugin = 1
require("oil").setup {
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  }
}
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, })
vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true,})

-- fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

-- TODO: cool ascii title
-- LSP
require("lze").load("vico.plugin.lsp")

-- ▗▞▀▚▖   ■  ▗▞▀▘▗▞▀▚▖   ■  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌
-- ▐▛▀▀▘▗▄▟▙▄▖▝▚▄▖▐▛▀▀▘▗▄▟▙▄▖▐▛▀▀▘█    ▝▚▄▟▌
-- ▝▚▄▄▖  ▐▌      ▝▚▄▄▖  ▐▌  ▝▚▄▄▖█
--        ▐▌             ▐▌
--        ▐▌             ▐▌

require("lze").load {
  { import = "vico.plugin.treesitter" },
  { import = "vico.plugin.telescope" },
  {
    "blink.cmp",
    enable = nixCats('ide.cmp'),
    event = { "DeferredUIEnter" },
    on_require = { "blink.cmp" },
    after = function(_)
      require("blink.cmp").setup({
        keymap = { preset = 'default' },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      })
    end
  },
}
