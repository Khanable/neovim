return {
  "saghen/blink.cmp",
  dependencies = { "ribru17/blink-cmp-spell" },
  opts = {
    -- ...

    sources = {
      default = {
        -- ...
        "spell",
      },
      providers = {
        -- ...
        spell = {
          name = "Spell",
          module = "blink-cmp-spell",
          opts = {
            -- EXAMPLE: Only enable source in `@spell` captures, and disable it
            -- in `@nospell` captures.
            enable_in_context = function()
              local curpos = vim.api.nvim_win_get_cursor(0)
              local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
              local in_spell_capture = false
              for _, cap in ipairs(captures) do
                if cap.capture == "spell" then
                  in_spell_capture = true
                elseif cap.capture == "nospell" then
                  return false
                end
              end
              return in_spell_capture
            end,
          },
        },
      },
    },

    -- It is recommended to put the "label" sorter as the primary sorter for the
    -- spell source.
    -- If you set use_cmp_spell_sorting to true, you may want to skip this step.
    fuzzy = {
      sorts = {
        function(a, b)
          local sort = require("blink.cmp.fuzzy.sort")
          if a.source_id == "spell" and b.source_id == "spell" then
            return sort.label(a, b)
          end
        end,
        -- This is the normal default order, which we fall back to
        "score",
        "kind",
        "label",
      },
    },
  },
}
