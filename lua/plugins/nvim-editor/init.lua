local M = {}

local SCRIPT = "nvim-editor"

local function plugin_dir()
  local src = debug.getinfo(1, "S").source
  if src:sub(1, 1) == "@" then
    src = src:sub(2)
  end
  return vim.fn.fnamemodify(src, ":h")
end

function M.install_script()
  local src_path = plugin_dir() .. "/scripts/" .. SCRIPT
  local dst_path = vim.fn.expand("~/.local/bin/" .. SCRIPT)

  vim.fn.mkdir(vim.fn.fnamemodify(dst_path, ":h"), "p")

  local in_f = io.open(src_path, "r")
  if not in_f then
    vim.notify("nvim-editor: missing script at " .. src_path, vim.log.levels.ERROR)
    return false
  end
  local content = in_f:read("*a")
  in_f:close()

  local out_f = io.open(dst_path, "w")
  if not out_f then
    vim.notify("nvim-editor: cannot write " .. dst_path, vim.log.levels.ERROR)
    return false
  end
  out_f:write(content)
  out_f:close()

  vim.fn.system({ "chmod", "+x", dst_path })
  return true
end

local function focus_terminal_insert()
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" then
        vim.api.nvim_set_current_win(win)
        vim.cmd.startinsert()
        return
      end
    end
  end)
end

function M.setup(opts)
  opts = vim.tbl_extend("force", {
    install_script = true,
    set_editor = true,
    save_close_keymap = true,
  }, opts or {})

  if opts.install_script and not M.install_script() then
    return
  end

  if opts.set_editor then
    vim.env.EDITOR = SCRIPT
    vim.env.VISUAL = SCRIPT
  end

  if opts.save_close_keymap then
    local map = LazyVim.safe_keymap_set
    map("n", "<leader>bs", function()
      vim.cmd.write()
      Snacks.bufdelete()
      focus_terminal_insert()
    end, { desc = "Save and Close Buffer" })
  end
end

return M
