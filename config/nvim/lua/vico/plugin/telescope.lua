return {
  {
    "telescope.nvim",
    keys = {
      { "<leader>pf", "<cmd>Telescope find_files<CR>", mode = {"n"} },
      { "<C-p>", "<cmd>Telescope find_git<CR>", mode = {"n"} },
      { "<leader>ps", function()
          require("telescope.builtin").grep_string({ search = vim.fn.input("[grep] >") });
        end, mode = {"n"} },
    },
  }
}
