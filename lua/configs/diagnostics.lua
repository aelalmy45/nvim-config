-- ============================================================
-- Diagnostics
-- ============================================================

local severity = vim.diagnostic.severity

-- ============================================================
-- Diagnostic Signs
-- ============================================================

local signs = {
  [severity.ERROR] = "󰅚 ",
  [severity.WARN] = "󰀪 ",
  [severity.HINT] = "󰌶 ",
  [severity.INFO] = "󰋼 ",
}

local sign_names = {
  [severity.ERROR] = "Error",
  [severity.WARN] = "Warn",
  [severity.HINT] = "Hint",
  [severity.INFO] = "Info",
}

for level, icon in pairs(signs) do
  local name = sign_names[level]
  local group = "DiagnosticSign" .. name

  vim.fn.sign_define(group, {
    text = icon,
    texthl = group,
    numhl = "",
  })
end

-- ============================================================
-- Floating Window Highlights
--
-- نستخدم ألوان الـ colorscheme الحالية.
-- ============================================================

vim.api.nvim_set_hl(0, "DiagnosticFloatTitle", {
  link = "Title",
})

vim.api.nvim_set_hl(0, "DiagnosticFloatError", {
  link = "DiagnosticError",
})

vim.api.nvim_set_hl(0, "DiagnosticFloatWarn", {
  link = "DiagnosticWarn",
})

vim.api.nvim_set_hl(0, "DiagnosticFloatHint", {
  link = "DiagnosticHint",
})

vim.api.nvim_set_hl(0, "DiagnosticFloatInfo", {
  link = "DiagnosticInfo",
})

-- ============================================================
-- Helpers
-- ============================================================

local function get_diagnostic_name(diagnostic)
  return sign_names[diagnostic.severity] or "Info"
end

local function get_diagnostic_icon(diagnostic)
  return signs[diagnostic.severity] or "● "
end

local function get_diagnostic_highlight(diagnostic)
  return "DiagnosticFloat" .. get_diagnostic_name(diagnostic)
end

-- ============================================================
-- Diagnostic Format
-- ============================================================

local function format_diagnostic(diagnostic)
  local message = diagnostic.message

  -- Source
  if diagnostic.source and diagnostic.source ~= "" then
    message = message .. "  [" .. diagnostic.source .. "]"
  end

  -- Diagnostic code
  if diagnostic.code then
    message = message .. "  (" .. tostring(diagnostic.code) .. ")"
  end

  return message
end

-- ============================================================
-- Diagnostic Configuration
-- ============================================================

vim.diagnostic.config {
  -- ----------------------------------------------------------
  -- Virtual Text
  -- ----------------------------------------------------------

  virtual_text = false,

  -- ----------------------------------------------------------
  -- Signs
  -- ----------------------------------------------------------

  signs = {
    text = signs,
  },

  -- ----------------------------------------------------------
  -- Underline
  -- ----------------------------------------------------------

  underline = true,

  -- ----------------------------------------------------------
  -- Update while typing
  -- ----------------------------------------------------------

  update_in_insert = true,

  -- ----------------------------------------------------------
  -- Severity
  -- ----------------------------------------------------------

  severity_sort = true,

  -- ----------------------------------------------------------
  -- Floating Diagnostics
  -- ----------------------------------------------------------

  float = {
    border = "rounded",

    source = "if_many",

    focusable = true,

    focus = false,

    header = " 󰅚 Diagnostics ",

    header_pos = "left",

    prefix = function(diagnostic)
      return get_diagnostic_icon(diagnostic), get_diagnostic_highlight(diagnostic)
    end,

    format = format_diagnostic,

    -- لا تجعل النافذة تأخذ الشاشة كلها.
    max_width = math.max(40, math.floor(vim.o.columns * 0.45)),

    max_height = math.max(5, math.floor(vim.o.lines * 0.35)),
    -- استخدم مكانًا مناسبًا حول الـ cursor.
    relative = "cursor",
  },
}

-- ============================================================
-- Custom Floating Diagnostic
-- ============================================================

local function show_diagnostic()
  vim.diagnostic.open_float(0, {
    scope = "cursor",

    focusable = true,

    focus = false,

    border = "rounded",

    source = "if_many",

    header = " 󰅚 Diagnostics ",

    header_pos = "left",

    prefix = function(diagnostic)
      return get_diagnostic_icon(diagnostic), get_diagnostic_highlight(diagnostic)
    end,

    format = format_diagnostic,

    max_width = math.max(40, math.floor(vim.o.columns * 0.45)),

    max_height = math.max(5, math.floor(vim.o.lines * 0.35)),

    relative = "cursor",
  })
end

-- ============================================================
-- Keymaps
--
-- D  -> Diagnostics
-- dd -> Neovim default: delete current line
-- ============================================================

vim.keymap.set("n", "D", show_diagnostic, {
  silent = true,
  desc = "Show diagnostics under cursor",
})

-- ============================================================
-- Insert → Normal
--
-- بعد الخروج من Insert:
-- أظهر رسالة الـ diagnostic بجانب السطر.
-- ============================================================

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.defer_fn(function()
      if vim.fn.mode() ~= "n" then
        return
      end

      vim.diagnostic.config {
        virtual_text = {
          spacing = 2,
          source = "if_many",
          prefix = "●",
        },
      }
    end, 100)
  end,
})

-- ============================================================
-- Normal → Insert
--
-- أثناء الكتابة:
-- أخفِ رسائل الـ diagnostic.
-- ============================================================

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.diagnostic.config {
      virtual_text = false,
    }
  end,
})
