local M = {}

-- ============================================================
-- LSP
-- ============================================================

function M.lsp()
  local utils = require "nvchad.stl.utils"
  local bufnr = utils.stbufnr()

  local clients = vim.lsp.get_clients {
    bufnr = bufnr,
  }

  if #clients == 0 then
    return ""
  end

  local names = {}

  for _, client in ipairs(clients) do
    names[#names + 1] = client.name
  end

  return "   " .. table.concat(names, " + ")
end

-- ============================================================
-- Mode
-- ============================================================

function M.mode()
  local utils = require "nvchad.stl.utils"

  if not utils.is_activewin() then
    return ""
  end

  local modes = utils.modes
  local mode = vim.api.nvim_get_mode().mode
  local current = modes[mode]

  if not current then
    return ""
  end

  local mode_name = current[1]
  local mode_group = current[2]

  return "%#St_" .. mode_group .. "Mode#  " .. mode_name .. "%#St_" .. mode_group .. "ModeSep#"
end

-- ============================================================
-- File State
-- ============================================================

function M.file_state()
  local bufnr = require("nvchad.stl.utils").stbufnr()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end

  local parts = {}

  if vim.bo[bufnr].modified then
    parts[#parts + 1] = "●"
  end

  if vim.bo[bufnr].readonly then
    parts[#parts + 1] = ""
  end

  if #parts == 0 then
    return ""
  end

  return " " .. table.concat(parts, " ")
end

-- ============================================================
-- File
-- ============================================================

function M.file()
  local utils = require "nvchad.stl.utils"
  local bufnr = utils.stbufnr()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end

  local path = vim.api.nvim_buf_get_name(bufnr)

  local name

  if path == "" then
    name = "Empty"
  else
    name = path:match "([^/\\]+)[/\\]*$"
  end

  local icon = "󰈚"

  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

  if devicons_ok and name ~= "Empty" then
    local ft_icon = devicons.get_icon(name)

    if ft_icon then
      icon = ft_icon
    end
  end

  local result = {
    "%#St_file# ",
    icon,
    " ",
    name,
  }

  if vim.bo[bufnr].modified then
    table.insert(result, " %#St_fileModified#●%*")
  end

  if vim.bo[bufnr].readonly then
    table.insert(result, " %#St_fileReadonly#%*")
  end

  return table.concat(result)
end

-- ============================================================
-- Highlights
-- ============================================================

vim.api.nvim_set_hl(0, "St_fileModified", {
  link = "DiagnosticWarn",
})

vim.api.nvim_set_hl(0, "St_fileReadonly", {
  link = "Comment",
})

return M
