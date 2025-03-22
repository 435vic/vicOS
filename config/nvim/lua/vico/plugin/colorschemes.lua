-- Automatically registers extra colorschemes defined in Nix
local specs = {}

for plugin, colorschemes in pairs(nixCats("themeIndex")) do
  table.insert(specs, {
    plugin,
    colorscheme = colorschemes,
  })
end

return specs
