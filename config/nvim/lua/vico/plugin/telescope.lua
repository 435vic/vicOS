local is_inside_worktree = {}
local telescope_opts = {
  hidden = true
}

-- Use git ls-files if a git repo is detected, otherwise
-- fall back to normal files
local function find_files()

  local cwd = vim.fn.getcwd()
  if is_inside_worktree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-worktree")
    is_inside_worktree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_worktree[cwd] then
    require("telescope.builtin").git_files(telescope_opts)
  else
    require("telescope.builtin").find_files(telescope_opts)
  end
end

local function find_string()
  require("telescope.builtin").grep_string({
    search = vim.fn.input("[grep] ")
  })
end

local function telescope(cmd)
  return function()
    require("telescope.builtin")[cmd](telescope_opts)
  end
end

--- @type lze.PluginSpec
return {
  "telescope.nvim",
  cmd = { "Telescope" },
  keys = {
    { "<leader><Space>", find_files, mode = {"n"}, desc = "Quick find files (Telescope)" },
    { "<leader>ff", telescope("find_files"), mode = {"n"}, desc = "Find files in project (Telescope)" },
    { "<leader>fl", telescope("live_grep"), mode = {"n"}, desc = "Live grep (Telescope)" },
    { "<leader>fs", find_string, mode = {"n"}, desc = "Find/grep string (Telescope)" },
    { "<leader>b", telescope("buffers"), mode = {"n"}, desc = "Find buffer (Telescope)" },
  },
}

