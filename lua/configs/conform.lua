local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    python = { "ruff_format" },

    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },

    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  },

  format_on_save = {
    timeout_ms = 1500,
    lsp_fallback = true,
  },
}

return options
