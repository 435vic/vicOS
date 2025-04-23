local vscode = require('vscode')

local function call(cmd)
  return function()
    vscode.call(cmd)
  end
end

vim.keymap.set('n', '<leader>pf', call 'workbench.action.quickOpen', { silent=true })
vim.keymap.set('n', '<leader>ps', call 'workbench.action.findInFiles', { silent=true })

