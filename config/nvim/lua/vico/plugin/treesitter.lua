--    ■   ▄▄▄ ▗▞▀▚▖▗▞▀▚▖ ▄▄▄ ▄    ■     ■  ▗▞▀▚▖ ▄▄▄
-- ▗▄▟▙▄▖█    ▐▛▀▀▘▐▛▀▀▘▀▄▄  ▄ ▗▄▟▙▄▖▗▄▟▙▄▖▐▛▀▀▘█
--   ▐▌  █    ▝▚▄▄▖▝▚▄▄▖▄▄▄▀ █   ▐▌    ▐▌  ▝▚▄▄▖█
--   ▐▌                      █   ▐▌    ▐▌
--   ▐▌                          ▐▌    ▐▌

return {
  {
    "nvim-treesitter",
    enabled = nixCats("general.treesitter"),
    event = "DeferredUIEnter",
    load = function (name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-treesitter-textobjects")
    end,
    after = function(_)
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true, },
        indent = { enable = false, },
      }
    end,
  }
}
