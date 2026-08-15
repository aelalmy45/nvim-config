require "nvchad.mappings"

-- add yours here
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- run file with 'r' in normal mode
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
    cpp = "g++ " .. filename .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",
    c = "gcc " .. filename .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",
    javascript = "node " .. filename,
    typescript = "ts-node " .. filename,
    sh = "bash " .. filename,
    bash = "bash " .. filename,
    zsh = "zsh " .. filename,
    lua = "lua " .. filename,
    rust = "rustc " .. filename .. " -o $HOME/tmp/a.out && $HOME/tmp/a.out",
    go = "go run " .. filename,
  }

  -- إنشاء مجلد tmp لو مش موجود
  vim.fn.mkdir(vim.fn.expand("$HOME/tmp"), "p")

  local cmd = commands[filetype]
  if cmd then
    vim.cmd("botright split | terminal " .. cmd)
    vim.cmd("startinsert")
  else
    vim.notify("No run command for " .. filetype, vim.log.levels.WARN)
  end
end, { desc = "Run current file" })

-- منع أخطاء modifiable
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "NvimTree*", "dashboard*", "alpha*", "starter*", "lazy*" },
  callback = function()
    vim.opt_local.modifiable = false
  end,
})



-------------------
-- التنقل السريع بين الملفات المفتوحة (Buffers)
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Buffer Go to next" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Buffer Go to previous" })

-- قفل الملف الحالي (الـ Buffer) الذكي بدون ما النوافذ تبوظ أو تقفل نيوفيم
map("n", "<leader>x", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Buffer Close current" })

-- البحث الفوري وسط الملفات المفتوحة باستخدام Telescope
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Telescope Find open buffers" })


-----------------

-- Harpoon
map("n", "<leader>ha", function() require("harpoon"):list():add() end, { desc = "Harpoon Add File" })
map("n", "<leader>hm", function()
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Menu" })
map("n", "<leader>1", function() require("harpoon"):list():select(1) end, { desc = "Harpoon File 1" })
map("n", "<leader>2", function() require("harpoon"):list():select(2) end, { desc = "Harpoon File 2" })
map("n", "<leader>3", function() require("harpoon"):list():select(3) end, { desc = "Harpoon File 3" })
map("n", "<leader>4", function() require("harpoon"):list():select(4) end, { desc = "Harpoon File 4" })

-- Diffview
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git Diff View" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Git File History" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Git Diff Close" })


---------------


-- Trouble (Problems panel)
map("n", "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>dq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })


----------------

-- Diagnostics

map("n", "]d", function()
  vim.diagnostic.jump({
    count = 1,
    float = true,
  })
end, { desc = "Diagnostics Next" })

map("n", "[d", function()
  vim.diagnostic.jump({
    count = -1,
    float = true,
  })
end, { desc = "Diagnostics Previous" })

---------------

-- File explorer
map("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Neo-tree Toggle" })
