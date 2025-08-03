--    ▗▞▀▚▖▄▄▄▄  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌█
--    ▐▛▀▀▘█   █ ▐▛▀▀▘█    ▝▚▄▟▌█
--    ▝▚▄▄▖█   █ ▝▚▄▄▖█         █
--  ▗▄▖                         █
-- ▐▌ ▐▌
--  ▝▀▜▌
-- ▐▙▄▞▘
require('vico.general')
require('vico.remap')

if nixCats('wsl') == true then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

local VicosGroup = vim.api.nvim_create_augroup('vico', {})

-- Highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = VicosGroup,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
           higroup = 'IncSearch',
           timeout = 60,
        })
    end,
})

vim.filetype.add({
  pattern = {
    ['.*/%.github[%w/]+workflows[%w/]+.*%.ya?ml'] = 'yaml.github',
  },
})

vim.diagnostic.config({ virtual_text = true })

-- █  ▄▄▄ ▄▄▄▄  
-- █ ▀▄▄  █   █ 
-- █ ▄▄▄▀ █▄▄▄▀ 
-- █      █     
--        ▀     
if nixCats("ide.lsp") then
  require("lze").load("vico.lsp")
end

-- ▄▄▄▄  █ █  ▐▌  ▄ ▄▄▄▄   ▄▄▄
-- █   █ █ ▀▄▄▞▘  ▄ █   █ ▀▄▄
-- █▄▄▄▀ █        █ █   █ ▄▄▄▀
-- █     █     ▗▄▖█
-- ▀          ▐▌ ▐▌
--             ▝▀▜▌
--            ▐▙▄▞▘

require('vico.plugin')

