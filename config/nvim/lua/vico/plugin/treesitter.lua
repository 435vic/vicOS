--    ■   ▄▄▄ ▗▞▀▚▖▗▞▀▚▖ ▄▄▄ ▄    ■     ■  ▗▞▀▚▖ ▄▄▄
-- ▗▄▟▙▄▖█    ▐▛▀▀▘▐▛▀▀▘▀▄▄  ▄ ▗▄▟▙▄▖▗▄▟▙▄▖▐▛▀▀▘█
--   ▐▌  █    ▝▚▄▄▖▝▚▄▄▖▄▄▄▀ █   ▐▌    ▐▌  ▝▚▄▄▖█
--   ▐▌                      █   ▐▌    ▐▌
--   ▐▌                          ▐▌    ▐▌

local log_file = vim.fn.stdpath("data") .. "/missing_parsers.log"

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
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start)
          if not ok then
            local log = io.open(log_file, "a")
            if log then
              log:write(string.format("[%s] Missing parser: %s\n",
              os.date("%Y-%m-%d %H:%M:%S"), args.match))
              log:close()
            end
          end
        end,
      })
    end,
  }
}
