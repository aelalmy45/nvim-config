require("nvchad.configs.lspconfig").defaults()
require("configs.diagnostics")

-- ts_ls
vim.lsp.config["ts_ls"] = {
  cmd = {
    "/data/data/com.termux/files/usr/bin/typescript-language-server",
    "--stdio",
  },

  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },

  root_markers = {
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    ".git",
  },
}

-- clangd
vim.lsp.config["clangd"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { ".clangd", "compile_commands.json", ".git" },
}

-- bashls
vim.lsp.config["bashls"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
}

-- vimls
vim.lsp.config["vimls"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/vim-language-server", "--stdio" },
  filetypes = { "vim" },
}

-- pyright
vim.lsp.config["pyright"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/pyright-langserver", "--stdio" },
  filetypes = { "python" },
}

-- ruff
vim.lsp.config["ruff"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/ruff", "server" },
  filetypes = { "python" },

  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.diagnosticProvider = false
  end,
}

-- lua_ls
vim.lsp.config["lua_ls"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
}

-- cssls
vim.lsp.config["cssls"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less", "tcss" },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  settings = {
    css = {
      validate = false,
      lint = {
        unknownProperties = "warning"
      }
    }
  }
}

-- emmet
vim.lsp.config["emmet_language_server"] = {
  cmd = { "/data/data/com.termux/files/usr/bin/emmet-language-server", "--stdio" },
  filetypes = {
    "css", "html", "javascript", "javascriptreact",
    "less", "sass", "scss", "typescript", "typescriptreact",
  },
}


local servers = {
  "clangd",
  "ruff",
  "pyright",
  "vimls",
  "bashls",
  "lua_ls",
  "cssls",
  "ts_ls",
  "emmet_language_server",
}
vim.lsp.enable(servers)
