vim.lsp.config("*", { root_markers = { ".git" } })
vim.lsp.config("nixd", { settings = { nixd = vim.empty_dict() } })
vim.lsp.config("basedpyright", {
    settings = { basedpyright = { allowedUntypedLibraries = { "socket" } } },
})
vim.lsp.config("jsonls", {
    settings = {
        json = {
            validate = { enable = true },
            schemas = {
                { fileMatch = { "package.json" }, url = "https://json.schemastore.org/package.json" },
                { fileMatch = { "tsconfig*.json" }, url = "https://json.schemastore.org/tsconfig.json" },
                {
                    fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
                    url = "https://json.schemastore.org/prettierrc.json",
                },
                { fileMatch = { ".eslintrc", ".eslintrc.json" }, url = "https://json.schemastore.org/eslintrc.json" },
                {
                    fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                    url = "https://json.schemastore.org/babelrc.json",
                },
                { fileMatch = { "lerna.json" }, url = "https://json.schemastore.org/lerna.json" },
                { fileMatch = { "now.json", "vercel.json" }, url = "https://json.schemastore.org/now.json" },
                {
                    fileMatch = { ".stylelintrc", ".stylelintrc.json", "stylelint.config.json" },
                    url = "https://json.schemastore.org/stylelintrc.json",
                },
            },
        },
    },
})

vim.lsp.enable({
    "lua_ls",
    "nixd",
    "jsonls",
    "tinymist",
    "yamlls",
    "html",
    "cssls",
    "emmet_language_server",
})

-- Project-specific servers come from the shell; Nix supplies the common ones.
for _, name in ipairs({ "clangd", "basedpyright", "hls", "denols" }) do
    if vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1 then
        vim.lsp.enable(name)
    end
end
