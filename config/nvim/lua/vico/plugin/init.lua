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

--  ▄▄▄  ▄ █ 
-- █   █ ▄ █ 
-- ▀▄▄▄▀ █ █ 
--       █ █ 
--
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

-- ▗▞▀▀▘█  ▐▌  ▄    ■  ▄ ▄   ▄ ▗▞▀▚▖
-- ▐▌   ▀▄▄▞▘  ▄ ▗▄▟▙▄▖▄ █   █ ▐▛▀▀▘
-- ▐▛▀▘        █   ▐▌  █  ▀▄▀  ▝▚▄▄▖
-- ▐▌       ▗▄▖█   ▐▌  █            
--         ▐▌ ▐▌   ▐▌               
--          ▝▀▜▌                    
--         ▐▙▄▞▘                    

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)


-- █  ▄▄▄ ▄▄▄▄  
-- █ ▀▄▄  █   █ 
-- █ ▄▄▄▀ █▄▄▄▀ 
-- █      █     
--        ▀     
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
          default = { 'lsp', 'path', 'snippets' },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" }
      })
    end
  },
  {
    "lualine.nvim",
    enabled = nixCats('ide.extra'),
    event = 'DeferredUIEnter',
    after = function(_)
      require('lualine').setup({
        options = {
          theme = colorscheme,
        },
        tabline = {
          lualine_a = { 'buffers' },
          -- if you use lualine-lsp-progress, I have mine here instead of fidget
          -- lualine_b = { 'lsp_progress', },
          lualine_z = { 'tabs' }
        },
      })
    end
  },
}
