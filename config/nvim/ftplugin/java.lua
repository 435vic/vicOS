require('jdtls').start_or_attach({
    cmd = { 'jdtls' },
    root_dir = vim.fs.dirname(vim.fs.find({'pom.xml', 'config.gradle', '.git'}, { upward = true })[1]),
})
