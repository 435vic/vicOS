--
-- ▗▞▀▘ ▄▄▄  █  ▄▄▄   ▄▄▄ ▄▄▄ ▗▞▀▘▐▌   ▗▞▀▚▖▄▄▄▄  ▗▞▀▚▖ ▄▄▄
-- ▝▚▄▖█   █ █ █   █ █   ▀▄▄  ▝▚▄▖▐▌   ▐▛▀▀▘█ █ █ ▐▛▀▀▘▀▄▄
--     ▀▄▄▄▀ █ ▀▄▄▄▀ █   ▄▄▄▀     ▐▛▀▚▖▝▚▄▄▖█   █ ▝▚▄▄▖▄▄▄▀
--           █                    ▐▌ ▐▌
--
-- The default colorscheme is loaded on startup
local colorscheme = nixCats("colorscheme")
vim.cmd.colorscheme(colorscheme)

-- Register extra plugins to be lazy loaded if enabled
if nixCats("extraThemes") then
  require("lze").load("vico.plugin.colorschemes")
end



-- ▗▞▀▚▖   ■  ▗▞▀▘▗▞▀▚▖   ■  ▗▞▀▚▖ ▄▄▄ ▗▞▀▜▌
-- ▐▛▀▀▘▗▄▟▙▄▖▝▚▄▖▐▛▀▀▘▗▄▟▙▄▖▐▛▀▀▘█    ▝▚▄▟▌
-- ▝▚▄▄▖  ▐▌      ▝▚▄▄▖  ▐▌  ▝▚▄▄▖█
--        ▐▌             ▐▌
--        ▐▌             ▐▌

require("lze").load {
  { import = "vico.plugin.treesitter" }
}
