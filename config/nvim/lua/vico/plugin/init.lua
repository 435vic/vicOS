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
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  }
}
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = "Explore parent folder (Oil)" })
vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = "Explore root folder (Oil)" })

-- ▗▞▀▀▘█  ▐▌  ▄    ■  ▄ ▄   ▄ ▗▞▀▚▖
-- ▐▌   ▀▄▄▞▘  ▄ ▗▄▟▙▄▖▄ █   █ ▐▛▀▀▘
-- ▐▛▀▘        █   ▐▌  █  ▀▄▀  ▝▚▄▄▖
-- ▐▌       ▗▄▖█   ▐▌  █            
--         ▐▌ ▐▌   ▐▌               
--          ▝▀▜▌                    
--         ▐▙▄▞▘                    

vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status (fugitive)", })


-- █  ▄▄▄ ▄▄▄▄  
-- █ ▀▄▄  █   █ 
-- █ ▄▄▄▀ █▄▄▄▀ 
-- █      █     
--        ▀     
if nixCats("ide.lsp") then
  require("lze").load("vico.plugin.lsp")
end

-- ▗▞▀▚▖   ■  ▗▞▀▘▗▞▀▚▖   ■  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌
-- ▐▛▀▀▘▗▄▟▙▄▖▝▚▄▖▐▛▀▀▘▗▄▟▙▄▖▐▛▀▀▘█    ▝▚▄▟▌
-- ▝▚▄▄▖  ▐▌      ▝▚▄▄▖  ▐▌  ▝▚▄▄▖█
--        ▐▌             ▐▌
--        ▐▌             ▐▌

require("lze").load {
  { import = "vico.plugin.treesitter" },
  {
    "telescope.nvim",
    cmd = { "Telescope" },
    keys = {
      { "<leader>pf", "<cmd>Telescope find_files<CR>", mode = {"n"}, desc = "Find files in project (Telescope)" },
      { "<C-p>", "<cmd>Telescope git_files<CR>", mode = {"n"}, desc = "Find git files in project (Telescope)" },
      { "<leader>ps", "<cmd>Telescope live_grep<CR>", mode = {"n"}, desc = "Grep for string in project (Telescope)" },
      { "<leader>b", "<cmd>Telescope buffers<CR>", mode = {"n"}, desc = "Find buffer (Telescope)" },
    },
  },
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
  {
    "which-key.nvim",
    enabled = nixCats('training'),
    event = 'DeferredUIEnter',
    keys = {
      { "<leader>?", function() require('which-key').show({ global = false }) end, desc = "Buffer Local Keymaps (which-key)", }
    },
  },
  {
    "vim-be-good",
    enabled = nixCats('training'),
    cmd = { "VimBeGood" },
  },
  {
    "presence.nvim",
    enabled = nixCats('misc'),
    event = 'DeferredUIEnter',
    after = function()
      require("presence").setup({
        neovim_image_text = "i use neovim btw",
        main_image = "file",
        --log_level = "debug",
      })
    end,
  },
}
