return {
  name = "nvim-editor",
  dir = vim.fn.stdpath("config") .. "/lua/plugins/nvim-editor",
  lazy = false,
  priority = 10000,
  build = function()
    require("nvim-editor").install()
  end,
  config = function()
    require("nvim-editor").setup()
  end,
}
