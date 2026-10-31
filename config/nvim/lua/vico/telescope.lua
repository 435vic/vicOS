local function picker(name)
    return function()
        require("telescope.builtin")[name]({ hidden = true })
    end
end

return {
    "telescope.nvim",
    cmd = "Telescope",
    after = function()
        require("telescope").setup({
            defaults = {
                mappings = {
                    n = { ["<C-p>"] = require("telescope.actions.layout").toggle_preview },
                },
            },
        })
    end,
    keys = {
        {
            "<leader><Space>",
            function()
                vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })
                picker(vim.v.shell_error == 0 and "git_files" or "find_files")()
            end,
            desc = "Quick find files",
        },
        { "<leader>ff", picker("find_files"), desc = "Find project files" },
        { "<leader>fl", picker("live_grep"), desc = "Live grep" },
        {
            "<leader>fs",
            function()
                require("telescope.builtin").grep_string({ search = vim.fn.input("[grep] ") })
            end,
            desc = "Find string",
        },
        { "<leader>fd", picker("diagnostics"), desc = "Find diagnostics" },
        { "<leader>b", picker("buffers"), desc = "Find buffer" },
    },
}
