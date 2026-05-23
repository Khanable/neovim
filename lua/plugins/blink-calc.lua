return {
  "saghen/blink.cmp",
  dependencies = { { "joelazar/blink-calc" } },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "calc" },
      providers = {
        calc = {
          name = "Calc",
          module = "blink-calc",
        },
      },
    },
  },
}
