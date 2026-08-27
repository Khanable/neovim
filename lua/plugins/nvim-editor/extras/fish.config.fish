# Reference copy of the fish block managed by the nvim-editor plugin.
# The plugin merges this into ~/.config/fish/config.fish on startup.

# >>> nvim-editor >>>
# Managed by the nvim-editor Neovim plugin.
if set -q NVIM
    set -gx EDITOR nvim-editor
    set -gx VISUAL nvim-editor
else
    set -xga EDITOR /usr/bin/nvim
    set -xga VISUAL /usr/bin/nvim
end
# <<< nvim-editor <<<
