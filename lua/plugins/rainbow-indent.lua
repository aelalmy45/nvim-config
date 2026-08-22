-- ~/.config/nvim/lua/plugins/rainbow-indent.lua
return {
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("hlchunk").setup {
        chunk = {
          enable = true,
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
            -- Color Rainbow
            { fg = "#FF0202" },
            { fg = "#0000FF" },
            { fg = "#00FF00" },
            { fg = "#FFA700" },
            { fg = "#03D2FF" },
            { fg = "#FF0AFB" },
            { fg = "#A303FF" },
          },
        },
        line_num = {
          enable = true,
          style = "#61AFEF",
        },
        blank = {
          enable = false,
        },
      }
    end,
  },
}
