require("rose-pine").setup({ styles = { italic = false } })
vim.cmd.colorscheme("rose-pine")

require("oil").setup({
    skip_confirm_for_simple_edits = true,
    view_options = { show_hidden = true },
})
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Explore parent folder" })
vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { desc = "Explore working directory" })
vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
        end
    end,
})

require("lze").load({
    { import = "vico.telescope" },
    {
        "blink.cmp",
        event = "DeferredUIEnter",
        after = function()
            require("blink.cmp").setup({
                keymap = { preset = "default" },
                sources = { default = { "lsp", "path", "snippets" } },
                fuzzy = { implementation = "rust" },
            })
        end,
    },
    {
        "lualine.nvim",
        event = "DeferredUIEnter",
        after = function()
            require("lualine").setup({
                options = { theme = "rose-pine" },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { { "FugitiveHead", icon = "" } },
                    lualine_c = { "diagnostics", "filename" },
                },
                tabline = { lualine_a = { "buffers" }, lualine_z = { "tabs" } },
            })
        end,
    },
    {
        "which-key.nvim",
        event = "DeferredUIEnter",
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer-local keymaps",
            },
        },
        after = function()
            require("which-key").setup({})
        end,
    },
    {
        "conform.nvim",
        event = "DeferredUIEnter",
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                desc = "Format buffer",
            },
        },
        beforeAll = function()
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
        after = function()
            require("conform").setup({
                formatters_by_ft = {
                    yaml = { "prettierd", "prettier", stop_after_first = true },
                },
            })
        end,
    },
    {
        "lazydev.nvim",
        ft = "lua",
        after = function()
            require("lazydev").setup({
                enabled = function(root)
                    return not vim.uv.fs_stat(root .. "/.luarc.json") and not vim.uv.fs_stat(root .. "/.luarc.jsonc")
                end,
            })
        end,
    },
    { "nvim-jdtls", on_require = "jdtls" },
    { "markdown-preview.nvim", ft = "markdown" },
    {
        "typst-preview.nvim",
        ft = "typst",
        after = function()
            require("typst-preview").setup({})
        end,
    },
})
