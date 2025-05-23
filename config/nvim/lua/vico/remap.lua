vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank into system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line into system clipboard" })

-- replace/delete things without overwriting your register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "delete to black hole register" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "replace into black hole register" })

vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal insert mode" })

-- add definition keybind following the new 'gr' prefixed default vim commands
vim.keymap.set('n', 'grd', function() vim.lsp.buf.definition() end, { desc = "vim.lsp.buf.definition()" })

