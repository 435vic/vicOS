local is_inside_worktree = {}

-- Use git ls-files if a git repo is detected, otherwise
-- fall back to normal files
local function find_files()
  local opts = {}

  local cwd = vim.fn.getcwd()
  if is_inside_worktree[cwd] == nil then
    vim.fn.system("git rev-parse --is-inside-worktree")
    is_inside_worktree[cwd] = vim.v.shell_error == 0
  end

  if is_inside_worktree[cwd] then
    require("telescope.builtin").git_files(opts)
  else
    require("telescope.builtin").find_files(opts)
  end
end

local function find_string()
  require("telescope.builtin").grep_string({
    search = vim.fn.input("[grep] ")
  })
end

--- @type lze.PluginSpec
return {
  "telescope.nvim",
  cmd = { "Telescope" },
  keys = {
    { "<leader><Space>", find_files, mode = {"n"}, desc = "Quick find files (Telescope)" },
    { "<leader>ff", "<cmd>Telescope find_files<CR>", mode = {"n"}, desc = "Find files in project (Telescope)" },
    { "<leader>fl", "<cmd>Telescope live_grep<CR>", mode = {"n"}, desc = "Live grep (Telescope)" },
    { "<leader>fs", find_string, mode = {"n"}, desc = "Find/grep string (Telescope)" },
    { "<leader>b", "<cmd>Telescope buffers<CR>", mode = {"n"}, desc = "Find buffer (Telescope)" },
  },
}

