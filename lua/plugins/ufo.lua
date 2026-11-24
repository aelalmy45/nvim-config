return {
  {
    "kevinhwang91/nvim-ufo",

    dependencies = {
      "kevinhwang91/promise-async",
    },

    event = "BufReadPost",

    config = function()
      -- Folding appearance
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      vim.o.fillchars = "fold: ,foldopen:,foldclose:,foldsep: "
      -- UFO setup
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,

        fold_virt_text_handler = function(
            virtText,
            lnum,
            endLnum,
            width,
            truncate
        )
          local suffix = ("  󰁂 %d lines"):format(endLnum - lnum)
          local suffixWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - suffixWidth

          local result = {}
          local currentWidth = 0

          for _, chunk in ipairs(virtText) do
            local text = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(text)

            if currentWidth + chunkWidth <= targetWidth then
              table.insert(result, chunk)
            else
              local remaining = targetWidth - currentWidth

              if remaining > 0 then
                text = truncate(text, remaining)
                table.insert(result, { text, chunk[2] })
              end

              break
            end

            currentWidth = currentWidth + chunkWidth
          end

          table.insert(result, { suffix, "Comment" })

          return result
        end,
      })


      -- Automatic Folding on ModeChanged
      local ufo = require("ufo")

      vim.api.nvim_create_autocmd("ModeChanged", {
        group = vim.api.nvim_create_augroup("UfoAutoFold", {
          clear = true,
        }),

        pattern = "*",

        callback = function()
          local mode = vim.api.nvim_get_mode().mode

          if mode:sub(1, 1) == "i" then
            -- Open all folds in Insert mode
            ufo.openAllFolds()
          elseif mode:sub(1, 1) == "n" then
            -- Close all folds in Normal mode
            ufo.closeAllFolds()
          end
        end,
      })


      -- -- Smart Folding Mode
      -- local ufo = require("ufo")
      --
      -- local smart_fold_enabled = false
      --
      -- local function smart_fold()
      --   if not smart_fold_enabled then
      --     return
      --   end
      --
      --   -- Close all folds
      --   ufo.closeAllFolds()
      --
      --   -- Open only the fold containing the cursor
      --   vim.cmd("normal! zv")
      -- end
      --
      -- local fold_group = vim.api.nvim_create_augroup(
      --   "SmartFolding",
      --   { clear = true }
      -- )
      --
      -- vim.api.nvim_create_autocmd({
      --   "InsertEnter",
      --   "CursorMovedI",
      -- }, {
      --   group = fold_group,
      --   callback = smart_fold,
      -- })
      --
      -- vim.api.nvim_create_autocmd("InsertLeave", {
      --   group = fold_group,
      --   callback = function()
      --     if smart_fold_enabled then
      --       ufo.closeAllFolds()
      --     end
      --   end,
      -- })
      --
      -- -- Toggle Smart Folding
      -- vim.keymap.set("n", "<leader>uf", function()
      --   smart_fold_enabled = not smart_fold_enabled
      --
      --   if smart_fold_enabled then
      --     ufo.closeAllFolds()
      --     vim.notify("Smart Folding: ON", vim.log.levels.INFO)
      --   else
      --     vim.notify("Smart Folding: OFF", vim.log.levels.INFO)
      --   end
      -- end, {
      --   desc = "Toggle Smart Folding",
      -- })
    end,
  },
}
