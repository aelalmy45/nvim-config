return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  { import = "nvchad.blink.lazyspec" },


  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "configs.treesitter",
  },

  { import = "plugins.noice" },

  { import = "plugins.rainbow-indent" },


  { import = "plugins.harpoon" },
  { import = "plugins.diffview" },


  { import = "plugins.ts-autotag" },
  { import = "plugins.blink-snippets" },

  { import = "plugins.trouble" },

  { import = "plugins.neo-tree" },

  -- ✅ إلغاء Mason الأصلي بتاع NvChad بالكامل
  { "mason-org/mason.nvim", enabled = false },
}
