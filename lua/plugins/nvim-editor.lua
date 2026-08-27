return {
  name = "nvim-editor",
  dir = vim.fn.stdpath("config") .. "/lua/plugins/nvim-editor",
  lazy = false,
  priority = 10000,
  config = function()
    require("nvim-editor").setup()
  end,
}
