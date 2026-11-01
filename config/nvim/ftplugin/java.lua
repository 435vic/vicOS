if not vim.g.vscode and vim.fn.executable("jdtls") == 1 then
    local root = vim.fs.root(0, { "pom.xml", "settings.gradle", "build.gradle", ".git" }) or vim.fn.getcwd()
    root = vim.uv.fs_realpath(root) or root
    -- Separate writable Equinox configuration when the project changes its server.
    local server = vim.fn.sha256(vim.fn.resolve(vim.fn.exepath("jdtls")))
    local config_home = vim.env.XDG_CONFIG_HOME
    if not config_home or config_home == "" then
        config_home = vim.env.HOME .. "/.config"
    end
    local configuration = config_home .. "/jdtls/" .. server
    -- Hash the full project path: equally named checkouts must not share a workspace.
    local workspace = vim.fn.stdpath("state") .. "/jdtls/" .. vim.fn.sha256(root)
    vim.fn.mkdir(configuration, "p", 448)
    vim.fn.mkdir(workspace, "p", 448)

    require("jdtls").start_or_attach({
        cmd = { "jdtls", "-configuration", configuration, "-data", workspace },
        root_dir = root,
    })
end
