if vim.g.vscode then
    require('vico.general')
    require('vico.remap')
    require('vico.vscode')
else
    require('vico')
end
