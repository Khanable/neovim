return {
  dir = vim.fn.stdpath("config") .. "/lua/nvim-editor",
  lazy = false,
  dependencies = { "snacks.nvim" },
  build = function(_plugin)
    require("nvim-editor").install()
  end,
  config = function(_plugin)
    require("nvim-editor").setup()
  end,
}
