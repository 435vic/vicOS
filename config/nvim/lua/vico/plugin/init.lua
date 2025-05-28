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
if nixCats("extraThemes") ~= nil then
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
    enable = nixCats('ide.cmp') ~= nil,
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
    enabled = nixCats('ide.extra') ~= nil,
    event = 'DeferredUIEnter',
    after = function(_)
      require('lualine').setup({
        options = {
          theme = colorscheme,
        },
        sections = {
          lualine_a = {{
            'mode',
            fmt = function(s)
              local mode_map = {
                ['NORMAL'] = 'N',
                ['O-PENDING'] = 'N?',
                ['INSERT'] = 'I',
                ['VISUAL'] = 'V',
                ['V-BLOCK'] = 'VB',
                ['V-LINE'] = 'VL',
                ['V-REPLACE'] = 'VR',
                ['REPLACE'] = 'R',
                ['COMMAND'] = '!',
                ['SHELL'] = 'SH',
                ['TERMINAL'] = 'T',
                ['EX'] = 'X',
                ['S-BLOCK'] = 'SB',
                ['S-LINE'] = 'SL',
                ['SELECT'] = 'S',
                ['CONFIRM'] = 'Y?',
                ['MORE'] = 'M',
              }
              return mode_map[s] or s
            end
          }},
          lualine_b = { { 'FugitiveHead', icon='' } },
          lualine_c = { { 'diagnostics' }, 'filename' },
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
    enabled = nixCats('training') ~= nil,
    event = 'DeferredUIEnter',
    keys = {
      { "<leader>?", function() require('which-key').show({ global = false }) end, desc = "Buffer Local Keymaps (which-key)", }
    },
  },
  {
    "vim-be-good",
    enabled = nixCats('training') ~= nil,
    cmd = { "VimBeGood" },
  },
  {
    "presence.nvim",
    enabled = nixCats('misc') ~= nil,
    event = 'DeferredUIEnter',
    after = function()
      require("presence").setup({
        neovim_image_text = "i use neovim btw",
        main_image = "file",
        --log_level = "debug",
      })
    end,
  },
  {
    "markdown-preview.nvim",
    ft = { "markdown" },
  },
  {
    "typst-preview.nvim",
    ft = { "typst" },
    after = function()
      require('typst-preview').setup {}
    end
  },
  {
    "copilot.vim",
    enabled = nixCats('ai.copilot') ~= nil,
    on_require = 'copilot'
  },
  {
    "CopilotChat.nvim",
    enabled = nixCats('ai.copilot') ~= nil,
    cmd = { "CopilotChatOpen" },
    after = function()
      require("CopilotChat").setup {}
    end,
  },
  {
    "golf-vim",
    enabled = nixCats('misc') ~= nil,
    cmd = { "Golf" }
  },
}
