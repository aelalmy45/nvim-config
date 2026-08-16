local navic = require "nvim-navic"

-- ============================================================
-- Navic
-- ============================================================

navic.setup {
  lsp = {
    auto_attach = false,
  },

  highlight = true,

  depth_limit = 0,

  separator = " 󰁔 ",

  icons = {
    File = "󰈙 ",
    Module = "󰆧 ",
    Namespace = "󰌗 ",
    Package = "󰏗 ",

    Class = "󰌗 ",
    Method = "󰆧 ",
    Property = "󰜢 ",
    Field = "󰜢 ",

    Constructor = " ",
    Enum = " ",
    Interface = " ",

    Function = "󰊕 ",
    Variable = "󰀫 ",
    Constant = "󰏿 ",

    String = "󰀬 ",
    Number = "󰎠 ",
    Boolean = "󰨙 ",

    Array = "󰅪 ",
    Object = "󰅩 ",
    Key = "󰌋 ",
    Null = "󰟢 ",

    EnumMember = " ",
    Struct = "󰙅 ",
    Event = " ",
    Operator = "󰆕 ",
    TypeParameter = "󰊄 ",
  },
}

-- ============================================================
-- Base Highlights
-- ============================================================

-- Parent symbols
vim.api.nvim_set_hl(0, "NavicText", {
  link = "Comment",
})

-- Separator
vim.api.nvim_set_hl(0, "NavicSeparator", {
  link = "Comment",
})

-- ============================================================
-- Symbol Highlight Mapping
--
-- نستخدم ألوان الـ colorscheme نفسها بدل ألوان ثابتة.
-- ============================================================

local symbol_highlights = {
  File = "Directory",

  Module = "Include",
  Namespace = "Type",
  Package = "Type",

  Class = "Type",
  Method = "Function",

  Property = "Identifier",
  Field = "Identifier",

  Constructor = "Function",

  Enum = "Type",
  Interface = "Type",

  Function = "Function",
  Variable = "Identifier",
  Constant = "Constant",

  String = "String",
  Number = "Number",
  Boolean = "Boolean",

  Array = "Type",
  Object = "Type",
  Key = "Identifier",
  Null = "Constant",

  EnumMember = "Constant",
  Struct = "Type",

  Event = "Special",
  Operator = "Operator",
  TypeParameter = "Type",
}

-- ============================================================
-- Symbol Highlight Helpers
-- ============================================================

local function get_symbol_name(kind)
  return vim.lsp.protocol.SymbolKind[kind]
end

local function get_symbol_highlight(kind)
  local symbol_name = get_symbol_name(kind)

  if not symbol_name then
    return "NavicText"
  end

  return symbol_highlights[symbol_name] or "NavicText"
end

-- ============================================================
-- Current Symbol Highlights
--
-- نفس لون الـ Symbol + Bold
-- ============================================================

local function setup_current_highlight(kind_name, base_group)
  if not kind_name then
    return "NavicCurrent"
  end

  local group = "NavicCurrent" .. kind_name

  local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
    name = base_group,
    link = false,
  })

  if ok and hl then
    local current = {}

    if hl.fg then
      current.fg = hl.fg
    end

    if hl.bg then
      current.bg = hl.bg
    end

    if hl.sp then
      current.sp = hl.sp
    end

    current.bold = true

    vim.api.nvim_set_hl(0, group, current)

    return group
  end

  -- Fallback
  vim.api.nvim_set_hl(0, group, {
    link = base_group,
    bold = true,
  })

  return group
end

-- ============================================================
-- Excluded Filetypes
-- ============================================================

local excluded_filetypes = {
  NvimTree = true,
  ["neo-tree"] = true,

  TelescopePrompt = true,
  TelescopeResults = true,

  terminal = true,
  nofile = true,
  prompt = true,

  alpha = true,
  dashboard = true,
  lazy = true,
  mason = true,
}

-- ============================================================
-- Helpers
-- ============================================================

local function is_excluded(bufnr)
  local ft = vim.bo[bufnr].filetype

  return excluded_filetypes[ft] == true
end

local function escape_statusline(text)
  -- '%' له معنى خاص داخل statusline/winbar.
  return tostring(text):gsub("%%", "%%%%")
end

-- ============================================================
-- Breadcrumb Limit
--
-- نعرض آخر 5 Symbols فقط.
--
-- مثال:
--
-- Person
-- Data
-- Repository
-- Cache
-- Manager
-- validate
--
-- يصبح:
--
-- … → Data → Repository → Cache → Manager → validate
--
-- والـ current symbol دائمًا محفوظ.
-- ============================================================

local MAX_BREADCRUMB_ITEMS = 5

local function trim_breadcrumb(data)
  if #data <= MAX_BREADCRUMB_ITEMS then
    return data, false
  end

  local start_index = #data - MAX_BREADCRUMB_ITEMS + 1

  local trimmed = {}

  for index = start_index, #data do
    trimmed[#trimmed + 1] = data[index]
  end

  return trimmed, true
end

-- ============================================================
-- Custom Breadcrumb
-- ============================================================

function navic.get_custom_location(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end

  if is_excluded(bufnr) then
    return ""
  end

  if not navic.is_available(bufnr) then
    return ""
  end

  local data = navic.get_data(bufnr)

  if not data or #data == 0 then
    return ""
  end

  -- Limit breadcrumb depth.
  local visible_data, truncated = trim_breadcrumb(data)

  local result = {}

  -- ==========================================================
  -- Ellipsis
  -- ==========================================================

  if truncated then
    table.insert(result, "%#NavicSeparator#…%*")

    table.insert(result, "%#NavicSeparator# 󰁔 %*")
  end

  -- ==========================================================
  -- Symbols
  -- ==========================================================

  for index, item in ipairs(visible_data) do
    local is_current = index == #visible_data

    local name = escape_statusline(item.name or "")
    local icon = item.icon or ""

    local symbol_name = get_symbol_name(item.kind)

    local symbol_group = get_symbol_highlight(item.kind)

    -- --------------------------------------------------------
    -- Current symbol
    -- --------------------------------------------------------

    local name_group = symbol_group

    if is_current then
      name_group = setup_current_highlight(symbol_name, symbol_group)
    end

    -- --------------------------------------------------------
    -- Icon
    -- --------------------------------------------------------

    table.insert(result, "%#" .. symbol_group .. "#" .. escape_statusline(icon) .. "%*")

    -- --------------------------------------------------------
    -- Name
    -- --------------------------------------------------------

    table.insert(result, "%#" .. name_group .. "#" .. name .. "%*")

    -- --------------------------------------------------------
    -- Separator
    -- --------------------------------------------------------

    if index < #visible_data then
      table.insert(result, "%#NavicSeparator# 󰁔 %*")
    end
  end

  return table.concat(result)
end

-- ============================================================
-- Winbar
-- ============================================================

function navic.update_winbar(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local show = navic.is_available(bufnr) and not is_excluded(bufnr)

  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    if vim.api.nvim_win_is_valid(win) then
      if show then
        vim.api.nvim_set_option_value("winbar", "%{%v:lua.require'configs.navic'.get_custom_location()%}", {
          win = win,
        })
      else
        vim.api.nvim_set_option_value("winbar", "", {
          win = win,
        })
      end
    end
  end
end

-- ============================================================
-- LSP Attach
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    -- Navic only works when the LSP provides
    -- document symbols.

    if client.server_capabilities.documentSymbolProvider then
      navic.attach(client, bufnr)

      vim.schedule(function()
        navic.update_winbar(bufnr)
      end)
    end
  end,
})

-- ============================================================
-- Update Breadcrumb
-- ============================================================

vim.api.nvim_create_autocmd({
  "CursorMoved",
  "CursorMovedI",
  "BufEnter",
  "WinEnter",
  "BufWinEnter",
}, {
  callback = function(args)
    vim.schedule(function()
      navic.update_winbar(args.buf)
    end)
  end,
})

-- ============================================================
-- Cleanup
-- ============================================================

vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_option_value("winbar", "", {
          win = win,
        })
      end
    end
  end,
})

return navic
