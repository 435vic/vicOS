--    ▗▞▀▚▖▄▄▄▄  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌█
--    ▐▛▀▀▘█   █ ▐▛▀▀▘█    ▝▚▄▟▌█
--    ▝▚▄▄▖█   █ ▝▚▄▄▖█         █
--  ▗▄▖                         █
-- ▐▌ ▐▌
--  ▝▀▜▌
-- ▐▙▄▞▘
require('vico.general')
require('vico.remap')

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

-- Add LSP handler to lze
require('lze').register_handlers(require('lzextras').lsp)

require('vico.plugin')

