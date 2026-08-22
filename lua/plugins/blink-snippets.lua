-- ~/.config/nvim/lua/plugins/blink-snippets.lua

return {
  {
    "saghen/blink.cmp",

    dependencies = {
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "nvim-tree/nvim-web-devicons",
      "xzbdmw/colorful-menu.nvim",
    },

    opts = {
      appearance = {
        nerd_font_variant = "normal",
        kind_icons = {
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰊕",
          Constructor = "󰒓",
          Field = "󰜢",
          Variable = "󰂡",
          Property = "󰜢",
          Class = "󰠱",
          Interface = "󰜰",
          Struct = "󰙅",
          Module = "󰕳",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "󰕘",
          EnumMember = "󰕘",
          Keyword = "󰌋",
          Constant = "󰏿",
          Snippet = "󰘍",
          Color = "󰏘",
          File = "󰈙",
          Reference = "󰈇",
          Folder = "󰉋",
          Event = "󱐋",
          Operator = "󰆕",
          TypeParameter = "󰅲",
        },
      },

      completion = {
        menu = {
          min_width = 30,
          max_height = 13,
          border = "single",
          scrollbar = true,

          draw = {
            padding = { 1, 1 },
            gap = 1,

            columns = {
              { "kind_icon", gap = 1 },
              { "label", gap = 1 },
              { "kind", gap = 2 },
            },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "single",
            max_width = 80,
            max_height = 20,
          },
        },
      },
    },

    config = function(_, opts)
      local blink = require "blink.cmp"
      local colorful = require "colorful-menu"

      local kind_colors = {
        Text = "#3cec85",
        Method = "#69c3ff",
        Function = "#69c3ff",
        Constructor = "#69c3ff",
        Field = "#ff738a",
        Variable = "#22ecdb",
        Property = "#ff738a",
        Class = "#12c7c4",
        Interface = "#3cec85",
        Struct = "#22ecdb",
        Module = "#eacd61",
        Unit = "#22ecdb",
        Value = "#22ecdb",
        Enum = "#69c3ff",
        EnumMember = "#bd93ff",
        Keyword = "#08bdba",
        Constant = "#ff955c",
        Snippet = "#ff738a",
        Color = "#abb7c1",
        File = "#08bdba",
        Reference = "#c3cfd9",
        Folder = "#08bdba",
        Event = "#eacd61",
        Operator = "#c3cfd9",
        TypeParameter = "#ff738a",
      }

      for kind, color in pairs(kind_colors) do
        vim.api.nvim_set_hl(0, "BlinkCmpKind" .. kind, { fg = color })
      end

      opts.completion.menu.draw.components = opts.completion.menu.draw.components or {}

      -- الأيقونة: lspkind للـ LSP kinds العادية، nvim-web-devicons لأيقونات الملفات (Path source)
      opts.completion.menu.draw.components.kind_icon = {
        text = function(ctx)
          local icon = ctx.kind_icon

          if vim.tbl_contains({ "Path" }, ctx.source_name) then
            local ok, devicons = pcall(require, "nvim-web-devicons")
            if ok then
              local dev_icon, _ = devicons.get_icon(ctx.label)
              if dev_icon then
                icon = dev_icon
              end
            end
          else
            local ok, lspkind = pcall(require, "lspkind")
            if ok then
              icon = lspkind.symbolic(ctx.kind, {
                mode = "symbol",
                preset = "material", -- "default" , "material" , "fontawesome"
              }) or icon
            end
          end

          return icon .. ctx.icon_gap
        end,

        highlight = function(ctx)
          local hl = "BlinkCmpKind" .. ctx.kind
          if vim.tbl_contains({ "Path" }, ctx.source_name) then
            local ok, devicons = pcall(require, "nvim-web-devicons")
            if ok then
              local dev_icon, dev_hl = devicons.get_icon(ctx.label)
              if dev_icon then
                hl = dev_hl
              end
            end
          end
          return hl
        end,
      }

      -- اللابل: colorful-menu بيدي التلوين + عرض الـ label والـ detail مع بعض.
      -- width.max هو الإصلاح الأساسي: بيمنع أي اقتراح طويل (زي اسم موديول بايثون)
      -- من إنه يمدد القائمة كلها بره حدود الشاشة.
      opts.completion.menu.draw.components.label = {
        width = { fill = true, max = 40 },
        text = function(ctx)
          return colorful.blink_components_text(ctx)
        end,
        highlight = function(ctx)
          return colorful.blink_components_highlight(ctx)
        end,
      }

      -- الـ kind: نفس الفكرة، سقف عرض + ellipsis عشان كلمات زي
      -- "TypeParameter" أو "Constructor" تتقطع بـ "…" بشكل واضح مش تتكسر فجأة
      opts.completion.menu.draw.components.kind = {
        width = { max = 12 },
        ellipsis = true,
        text = function(ctx)
          return ctx.kind
        end,
        highlight = function(ctx)
          return "BlinkCmpKind" .. ctx.kind
        end,
      }

      blink.setup(opts)
    end,
  },
}
