-- ~/.config/nvim/lua/plugins/rainbow-indent.lua
return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          -- تعطيل chunk عشان ما يتعارضش
        },
        indent = {
          enable = true,
          chars = {
            "┊",
            "┊",
            "┊",
            "┊",
            "┊",
            "┊",
            "┊",
          },
          style = {
            -- Rainbow هادي جداً (ألوان شفافة تقريباً)
            -- { fg = "#5A3E4B" }, -- أحمر غامق هادي
            -- { fg = "#5A4D3E" }, -- برتقالي غامق
            -- { fg = "#4D5A3E" }, -- أخضر غامق
            -- { fg = "#3E5A5A" }, -- أزرق غامق
            -- { fg = "#3E3E5A" }, -- بنفسجي غامق
            -- { fg = "#4A3E5A" }, -- لافندر غامق
            -- { fg = "#5A3E4B" }, -- رجوع للأحمر
            --
            -- Color Rainbow
            { fg = "#990000" },
            { fg = "#998000" },
            { fg = "#999900" },
            { fg = "#009900" },
            { fg = "#009999" },
            { fg = "#000099" },
            { fg = "#800099" },
          },      
        },
        line_num = {
          enable = true,
          style = "#61AFEF",
        },
        blank = {
          enable = false,
        },
      })
    end,
  },
}
