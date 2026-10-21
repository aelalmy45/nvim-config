local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    python = { "ruff_fix", "ruff_format" },

    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },

    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
  },

  formatters = {
    ruff_fix = {
      command = "ruff",
      args = { "check", "--fix", "$FILENAME" },
      stdin = false,
      exit_codes = { 0, 1 },
    },
  },

  format_on_save = {
    timeout_ms = 3000,
    lsp_fallback = true,
  },
}

return options
