local M = {}

local SCRIPT = "nvim-editor"
local FISH_START = "# >>> nvim-editor >>>"
local FISH_END = "# <<< nvim-editor <<<"

local function plugin_dir()
  local src = debug.getinfo(1, "S").source
  if src:sub(1, 1) == "@" then
    src = src:sub(2)
  end
  return vim.fn.fnamemodify(src, ":h")
end

local function fish_snippet_lines()
  return {
    FISH_START,
    "# Managed by the nvim-editor Neovim plugin.",
    "if set -q NVIM",
    "    set -gx EDITOR nvim-editor",
    "    set -gx VISUAL nvim-editor",
    "else",
    "    set -xga EDITOR /usr/bin/nvim",
    "    set -xga VISUAL /usr/bin/nvim",
    "end",
    FISH_END,
  }
end

local function read_lines(path)
  local f = io.open(path, "r")
  if not f then
    return {}
  end
  local lines = {}
  for line in f:lines() do
    table.insert(lines, line)
  end
  f:close()
  return lines
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

local function write_lines(path, lines)
  local f = io.open(path, "w")
  if not f then
    return false
  end
  f:write(table.concat(lines, "\n"))
  if #lines == 0 or lines[#lines] ~= "" then
    f:write("\n")
  end
  f:close()
  return true
end

local function lines_to_text(lines)
  if #lines == 0 then
    return "\n"
  end
  local text = table.concat(lines, "\n")
  if lines[#lines] ~= "" then
    text = text .. "\n"
  end
  return text
end

local function strip_legacy_fish_editor(lines)
  local out = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line == FISH_START then
      i = i + 1
      while i <= #lines and lines[i] ~= FISH_END do
        i = i + 1
      end
      if i <= #lines then
        i = i + 1
      end
    elseif line:match("^if set %-q NVIM") then
      i = i + 1
      while i <= #lines and lines[i] ~= "end" do
        i = i + 1
      end
      if i <= #lines then
        i = i + 1
      end
    elseif line:match("^set %-xga EDITOR")
      or line:match("^set %-xga VISUAL")
      or line:match("^set %-gx EDITOR nvim%-editor")
      or line:match("^set %-gx VISUAL nvim%-editor") then
      i = i + 1
    else
      table.insert(out, line)
      i = i + 1
    end
  end
  return out
end

local function merged_fish_lines()
  local path = vim.fn.expand("~/.config/fish/config.fish")
  local lines = read_lines(path)
  local start_idx, end_idx

  for i, line in ipairs(lines) do
    if line == FISH_START then
      start_idx = i
    elseif line == FISH_END then
      end_idx = i
    end
  end

  local snippet = fish_snippet_lines()
  local merged

  if start_idx and end_idx and end_idx >= start_idx then
    merged = {}
    vim.list_extend(merged, vim.list_slice(lines, 1, start_idx - 1))
    vim.list_extend(merged, snippet)
    vim.list_extend(merged, vim.list_slice(lines, end_idx + 1))
  else
    merged = strip_legacy_fish_editor(lines)
    if #merged > 0 and merged[#merged] ~= "" then
      table.insert(merged, "")
    end
    vim.list_extend(merged, snippet)
  end

  while #merged > 1 and merged[#merged] == "" and merged[#merged - 1] == "" do
    table.remove(merged)
  end

  return merged, path
end

function M.merge_fish_config()
  local merged, path = merged_fish_lines()
  local desired = lines_to_text(merged)
  local current = read_file(path)

  if current == desired then
    return true
  end

  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  if not write_lines(path, merged) then
    vim.notify("nvim-editor: cannot write " .. path, vim.log.levels.ERROR)
    return false
  end

  return true
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

  local current = read_file(dst_path)
  if current ~= content then
    local out_f = io.open(dst_path, "w")
    if not out_f then
      vim.notify("nvim-editor: cannot write " .. dst_path, vim.log.levels.ERROR)
      return false
    end
    out_f:write(content)
    out_f:close()
  end

  vim.fn.system({ "chmod", "+x", dst_path })
  return true
end

function M.install()
  local ok_script = M.install_script()
  local ok_fish = M.merge_fish_config()
  return ok_script and ok_fish
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
    set_editor = true,
    save_close_keymap = true,
  }, opts or {})

  vim.api.nvim_create_user_command("NvimEditorInstall", function()
    if M.install() then
      vim.notify("nvim-editor: install complete", vim.log.levels.INFO)
    end
  end, { desc = "Install nvim-editor bin script and fish config" })

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
