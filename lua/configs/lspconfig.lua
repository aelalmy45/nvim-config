require("nvchad.configs.lspconfig").defaults()
require "configs.diagnostics"
require "configs.navic"

-- ============================================================
-- LSP Servers
-- ============================================================

-- C / C++
vim.lsp.config["clangd"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = {
    ".clangd",
    "compile_commands.json",
    ".git",
  },
}

-- Python - Pyright
vim.lsp.config["pyright"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/pyright-langserver",
    "--stdio",
  },
  filetypes = { "python" },
}

-- Python - Ruff
vim.lsp.config["ruff"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/ruff",
    "server",
  },
  filetypes = { "python" },

  on_attach = function(client, bufnr)
    -- Conform handles formatting.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}

-- Lua
vim.lsp.config["lua_ls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/lua-language-server",
  },
  filetypes = { "lua" },

  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },

      diagnostics = {
        globals = { "vim" },
      },

      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
}

-- CSS
vim.lsp.config["cssls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/vscode-css-language-server",
    "--stdio",
  },

  filetypes = {
    "css",
    "scss",
    "less",
  },

  on_attach = function(client, bufnr)
    -- Conform handles formatting.
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,

  settings = {
    css = {
      validate = false,

      lint = {
        unknownProperties = "warning",
      },
    },
  },
}

-- TypeScript / JavaScript
vim.lsp.config["ts_ls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/typescript-language-server",
    "--stdio",
  },

  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },

  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
}

-- ============================================================
-- Optional LSP Servers
--
-- محفوظة هنا ولكن غير مفعّلة.
-- يمكن تفعيلها لاحقًا بإضافتها إلى القائمة الموجودة
-- في الأسفل.
-- ============================================================

-- Bash / Zsh
vim.lsp.config["bashls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/bash-language-server",
    "start",
  },

  filetypes = {
    "sh",
    "bash",
    "zsh",
  },
}

-- Vimscript
vim.lsp.config["vimls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/vim-language-server",
    "--stdio",
  },

  filetypes = {
    "vim",
  },
}

-- Emmet
vim.lsp.config["emmet_language_server"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/emmet-language-server",
    "--stdio",
  },

  filetypes = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "typescript",
    "typescriptreact",
  },
}

-- ============================================================
-- Enable LSP Servers
-- ============================================================

vim.lsp.enable {
  "clangd",
  "pyright",
  "ruff",
  "lua_ls",
  "cssls",
  "ts_ls",
}

-- ============================================================
-- LSP Keymaps
--
-- يتم إنشاء الاختصارات فقط عندما يتصل LSP بالـ buffer.
-- ============================================================

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        silent = true,
        desc = "LSP: " .. desc,
      })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
    map("n", "gr", vim.lsp.buf.references, "Find References")
    map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")

    -- Documentation
    map("n", "K", vim.lsp.buf.hover, "Hover Documentation")

    -- Refactoring
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

    -- Type information
    map("n", "<leader>D", vim.lsp.buf.type_definition, "Type Definition")

    -- Symbols
    map("n", "<leader>ld", vim.lsp.buf.document_symbol, "Document Symbols")
    map("n", "<leader>ls", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
  end,
})
