local M = {}

-- ============================================================
-- LSP
-- ============================================================

function M.lsp()
  local clients = vim.lsp.get_clients {
    bufnr = vim.api.nvim_get_current_buf(),
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

return M
