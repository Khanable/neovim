return {
  {
    "rest-nvim/rest.nvim",
    build = false, -- Prevents lazy.nvim from running rest.nvim's rockspec
    dependencies = {
      "nvim-neotest/nvim-nio",
      "j-hui/fidget.nvim",
      {
        "rest-nvim/tree-sitter-http",
        build = "mkdir -p parser && make", -- Compiles parser/http.so directly
      },
      {
        "lunarmodules/lua-mimetypes",
        config = function(plugin)
          package.path = package.path .. ";" .. plugin.dir .. "/?.lua"
        end,
      },
      {
        "manoelcampos/xml2lua",
        config = function(plugin)
          package.path = package.path .. ";" .. plugin.dir .. "/?.lua"
        end,
      },
    },
  },
}
