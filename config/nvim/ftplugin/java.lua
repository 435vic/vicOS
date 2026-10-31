if not vim.g.vscode and vim.fn.executable("jdtls") == 1 then
    require("jdtls").start_or_attach({
        cmd = { "jdtls" },
        root_dir = vim.fs.root(0, { "pom.xml", "settings.gradle", "build.gradle", ".git" }),
    })
end
