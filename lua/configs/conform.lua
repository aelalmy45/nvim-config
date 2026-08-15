local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    python = { "ruff_format" },

    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
