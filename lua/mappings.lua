require "nvchad.mappings"

local map = vim.keymap.set

-- ============================================================
-- General
-- ============================================================

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>")


-- ============================================================
-- Run Current File
-- ============================================================

map("n", "r", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")

  -- تجاهل الملفات غير المحفوظة
  if filename == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  -- احفظ الملف لو قابل للتعديل
  if vim.bo.modifiable then
    vim.cmd("silent! write")
  end

  local commands = {
    python = "python " .. filename,

    cpp = "g++ "
        .. filename
        .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",

    c = "gcc "
        .. filename
        .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",

    javascript = "node " .. filename,
    typescript = "ts-node " .. filename,

    sh = "bash " .. filename,
    bash = "bash " .. filename,
    zsh = "zsh " .. filename,

    lua = "lua " .. filename,

    rust = "rustc "
        .. filename
        .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",

    go = "go run " .. filename,
  }

  -- إنشاء مجلد tmp لو مش موجود
  vim.fn.mkdir(vim.fn.expand("$HOME/tmp"), "p")

  local cmd = commands[filetype]

  if cmd then
    vim.cmd("botright split | terminal " .. cmd)
    vim.cmd("startinsert")
  else
    vim.notify(
      "No run command for " .. filetype,
      vim.log.levels.WARN
    )
  end
end, { desc = "Run current file" })


-- ============================================================
-- Prevent Modifiable Errors
-- ============================================================

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = {
    "NvimTree*",
    "dashboard*",
    "alpha*",
    "starter*",
    "lazy*",
  },

  callback = function()
    vim.opt_local.modifiable = false
  end,
})


-- ============================================================
-- Buffers
-- ============================================================

-- التنقل السريع بين الملفات المفتوحة
map(
  "n",
  "<Tab>",
  "<cmd>bnext<CR>",
  { desc = "Buffer Go to next" }
)

map(
  "n",
  "<S-Tab>",
  "<cmd>bprevious<CR>",
  { desc = "Buffer Go to previous" }
)

-- إغلاق الـ Buffer الحالي
map(
  "n",
  "<leader>x",
  function()
    require("nvchad.tabufline").close_buffer()
  end,
  { desc = "Buffer Close current" }
)

-- البحث في الـ Buffers المفتوحة
map(
  "n",
  "<leader>fb",
  "<cmd>Telescope buffers<CR>",
  { desc = "Telescope Find open buffers" }
)


-- ============================================================
-- Harpoon
-- ============================================================

map(
  "n",
  "<leader>ha",
  function()
    require("harpoon"):list():add()
  end,
  { desc = "Harpoon Add File" }
)

map(
  "n",
  "<leader>hm",
  function()
    local harpoon = require("harpoon")

    harpoon.ui:toggle_quick_menu(
      harpoon:list()
    )
  end,
  { desc = "Harpoon Menu" }
)

map(
  "n",
  "<leader>1",
  function()
    require("harpoon"):list():select(1)
  end,
  { desc = "Harpoon File 1" }
)

map(
  "n",
  "<leader>2",
  function()
    require("harpoon"):list():select(2)
  end,
  { desc = "Harpoon File 2" }
)

map(
  "n",
  "<leader>3",
  function()
    require("harpoon"):list():select(3)
  end,
  { desc = "Harpoon File 3" }
)

map(
  "n",
  "<leader>4",
  function()
    require("harpoon"):list():select(4)
  end,
  { desc = "Harpoon File 4" }
)


-- ============================================================
-- Diffview
-- ============================================================

map(
  "n",
  "<leader>gd",
  "<cmd>DiffviewOpen<cr>",
  { desc = "Git Diff View" }
)

map(
  "n",
  "<leader>gh",
  "<cmd>DiffviewFileHistory<cr>",
  { desc = "Git File History" }
)

map(
  "n",
  "<leader>gq",
  "<cmd>DiffviewClose<cr>",
  { desc = "Git Diff Close" }
)


-- ============================================================
-- Trouble
-- ============================================================

map(
  "n",
  "<leader>dd",
  "<cmd>Trouble diagnostics toggle<cr>",
  { desc = "Diagnostics (Trouble)" }
)

map(
  "n",
  "<leader>db",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Buffer Diagnostics (Trouble)" }
)

-- مهم:
-- نحتفظ بهذا لأن Trouble يستخدم <leader>ds
map(
  "n",
  "<leader>ds",
  "<cmd>Trouble symbols toggle focus=false<cr>",
  { desc = "Symbols (Trouble)" }
)

map(
  "n",
  "<leader>dq",
  "<cmd>Trouble qflist toggle<cr>",
  { desc = "Quickfix List (Trouble)" }
)


-- ============================================================
-- Diagnostics
-- ============================================================

map(
  "n",
  "]d",
  function()
    vim.diagnostic.jump({
      count = 1,
      float = true,
    })
  end,
  { desc = "Diagnostics Next" }
)

map(
  "n",
  "[d",
  function()
    vim.diagnostic.jump({
      count = -1,
      float = true,
    })
  end,
  { desc = "Diagnostics Previous" }
)


-- ============================================================
-- LSP Navigation & Actions
-- ============================================================

-- Go to Definition
map(
  "n",
  "gd",
  vim.lsp.buf.definition,
  { desc = "LSP Go to Definition" }
)

-- Go to Declaration
map(
  "n",
  "gD",
  vim.lsp.buf.declaration,
  { desc = "LSP Go to Declaration" }
)

-- Find References
map(
  "n",
  "gr",
  vim.lsp.buf.references,
  { desc = "LSP Find References" }
)

-- Go to Implementation
map(
  "n",
  "gi",
  vim.lsp.buf.implementation,
  { desc = "LSP Go to Implementation" }
)

-- Go to Type Definition
map(
  "n",
  "gy",
  vim.lsp.buf.type_definition,
  { desc = "LSP Go to Type Definition" }
)

-- Hover Documentation
map(
  "n",
  "K",
  vim.lsp.buf.hover,
  { desc = "LSP Hover Documentation" }
)

-- Signature Help
map(
  "n",
  "<C-k>",
  vim.lsp.buf.signature_help,
  { desc = "LSP Signature Help" }
)

-- Code Actions
map(
  { "n", "v" },
  "<leader>ca",
  vim.lsp.buf.code_action,
  { desc = "LSP Code Action" }
)

-- Rename Symbol
map(
  "n",
  "<leader>rn",
  vim.lsp.buf.rename,
  { desc = "LSP Rename Symbol" }
)

-- Workspace Symbols
map(
  "n",
  "<leader>ws",
  vim.lsp.buf.workspace_symbol,
  { desc = "LSP Workspace Symbols" }
)


-- ============================================================
-- File Explorer
-- ============================================================

map(
  "n",
  "<C-n>",
  "<cmd>Neotree toggle<cr>",
  { desc = "Neo-tree Toggle" }
)
