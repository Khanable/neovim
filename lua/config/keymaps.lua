-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set
map({ "n" }, "<leader>pf", function()
  vim.uv.chdir(vim.fs.dirname(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())))
  print(vim.uv.cwd())
end, { desc = "cwd to file directory" })
map({ "n" }, "<leader>pr", function()
  vim.uv.chdir(LazyVim.root())
  print(vim.uv.cwd())
end, { desc = "cwd to root directory" })
map({ "n" }, "<leader>pu", function()
  local newDir = vim.fs.dirname(vim.uv.cwd())
  if newDir then
    vim.uv.chdir(newDir)
  end
  print(vim.uv.cwd())
end, { desc = "cwd up one directory" })
map({ "n" }, "<leader>ps", function()
  print(vim.uv.cwd())
end, { desc = "show cwd" })
