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
-- Highlights
-- ============================================================

-- Parent symbols
vim.api.nvim_set_hl(0, "NavicText", {
  link = "Comment",
})

-- Current symbol
vim.api.nvim_set_hl(0, "NavicCurrent", {
  link = "Normal",
  bold = true,
})

-- Separator
vim.api.nvim_set_hl(0, "NavicSeparator", {
  link = "Comment",
})

-- Icons
vim.api.nvim_set_hl(0, "NavicIconsClass", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsMethod", {
  link = "Function",
})

vim.api.nvim_set_hl(0, "NavicIconsFunction", {
  link = "Function",
})

vim.api.nvim_set_hl(0, "NavicIconsVariable", {
  link = "Identifier",
})

vim.api.nvim_set_hl(0, "NavicIconsProperty", {
  link = "Identifier",
})

vim.api.nvim_set_hl(0, "NavicIconsField", {
  link = "Identifier",
})

vim.api.nvim_set_hl(0, "NavicIconsConstructor", {
  link = "Function",
})

vim.api.nvim_set_hl(0, "NavicIconsNamespace", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsModule", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsPackage", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsConstant", {
  link = "Constant",
})

vim.api.nvim_set_hl(0, "NavicIconsEnum", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsInterface", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsStruct", {
  link = "Type",
})

vim.api.nvim_set_hl(0, "NavicIconsEnumMember", {
  link = "Constant",
})

vim.api.nvim_set_hl(0, "NavicIconsOperator", {
  link = "Operator",
})

vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {
  link = "Type",
})

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
  -- '%' has a special meaning inside statusline/winbar expressions.
  return tostring(text):gsub("%%", "%%%%")
end

local function icon_highlight(kind)
  local kind_name = vim.lsp.protocol.SymbolKind[kind]

  if not kind_name then
    return "NavicText"
  end

  return "NavicIcons" .. kind_name
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

  local result = {}

  for index, item in ipairs(data) do
    local is_current = index == #data

    local name = escape_statusline(item.name or "")
    local icon = item.icon or ""

    local icon_group = icon_highlight(item.kind)

    -- Icon
    table.insert(result, "%#" .. icon_group .. "#" .. escape_statusline(icon) .. "%*")

    -- Name
    if is_current then
      table.insert(result, "%#NavicCurrent#" .. name .. "%*")
    else
      table.insert(result, "%#NavicText#" .. name .. "%*")
    end

    -- Separator
    if index < #data then
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

    -- Only attach to LSPs that provide document symbols.
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
