vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank into system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line into system clipboard" })

vim.keymap.set({"n", "v"}, "<leader>d", [[\"_d]])

