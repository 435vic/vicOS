vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line into system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without replacing register" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Replace without replacing register" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal insert mode" })
vim.keymap.set("n", "grd", vim.lsp.buf.definition, { desc = "Go to definition" })

if vim.g.vscode then
    vim.keymap.set("n", "<leader>pf", function()
        require("vscode").call("workbench.action.quickOpen")
    end)
    vim.keymap.set("n", "<leader>ps", function()
        require("vscode").call("workbench.action.findInFiles")
    end)
    return
end

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 60 })
    end,
})
vim.diagnostic.config({ virtual_text = true })

require("vico.plugins")
require("vico.lsp")
