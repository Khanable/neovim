# Merge into ~/.config/fish/config.fish so EDITOR is not reset inside Neovim terminals.
if set -q NVIM
    set -gx EDITOR nvim-editor
    set -gx VISUAL nvim-editor
else
    set -xga EDITOR /usr/bin/nvim
    set -xga VISUAL /usr/bin/nvim
end
