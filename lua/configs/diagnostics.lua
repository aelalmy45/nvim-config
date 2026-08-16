-- ============================================================
-- Diagnostics
-- OXY2DEV Fancy Diagnostics integration
-- ============================================================

local signs = {
  Error = "󰅙 ",
  Warn = " ",
  Hint = "󰁨 ",
  Info = "󰀨 ",
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type

  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = "",
  })
end

-- ============================================================
-- Neovim diagnostics configuration
-- ============================================================

vim.diagnostic.config {
  virtual_text = false,

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.HINT] = signs.Hint,
      [vim.diagnostic.severity.INFO] = signs.Info,
    },
  },

  underline = true,
  update_in_insert = true,
  severity_sort = true,
}

-- ============================================================
-- Fancy Diagnostics highlights
-- ============================================================

local ok_highlights, highlights = pcall(require, "scripts.highlights")

if ok_highlights then
  highlights.setup()
else
  vim.notify("Failed to load Fancy Diagnostics highlights: " .. tostring(highlights), vim.log.levels.ERROR)
end

-- ============================================================
-- Fancy Diagnostics
-- ============================================================

local ok_diagnostics, diagnostics = pcall(require, "scripts.diagnostics")

if ok_diagnostics then
  diagnostics.setup()
else
  vim.notify("Failed to load Fancy Diagnostics: " .. tostring(diagnostics), vim.log.levels.ERROR)
end
