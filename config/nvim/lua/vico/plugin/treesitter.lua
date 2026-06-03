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
    load = function (name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-treesitter-textobjects")
      vim.api.nvim_create_autocmd('User', { pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers').lark = {}
        end,
      })
    end,
    after = function(_)
      local function start_treesitter(buf, filetype)
        if filetype == "" or vim.bo[buf].buftype ~= "" then
          return
        end

        local ok = pcall(vim.treesitter.start, buf)
        if not ok then
          local log = io.open(log_file, "a")
          if log then
            log:write(string.format("[%s] Missing parser: %s\n",
            os.date("%Y-%m-%d %H:%M:%S"), filetype))
            log:close()
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          start_treesitter(args.buf, args.match)
        end,
      })
    end,
  }
}
