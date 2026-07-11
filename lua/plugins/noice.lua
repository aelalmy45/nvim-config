-- ~/.config/nvim/lua/plugins/noice.lua

return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
        },
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = { border = { style = "rounded" } },
        },
        notify = {
          enabled = true,
          view = "notify",
        },
        lsp_progress = {
          enabled = true,
          format = "lsp_progress",
          view = "mini",
        },
        presets = {
          bottom_search = false,
          command_palette = false,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })

      -- اختصارات (اختياري)
      vim.keymap.set("n", "<leader>nh", function()
        require("noice").cmd("history")
      end, { desc = "Noice History" })

      vim.keymap.set("n", "<leader>nd", function()
        require("noice").cmd("dismiss")
      end, { desc = "Dismiss All Notifications" })
    end,
  },

  -- إضافة nvim-notify (ضرورية)
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        timeout = 5000,
        top_down = true,
      })
      vim.notify = require("notify")
    end,
  },
}
