-- ~/.config/nvim/lua/plugins/diffview.lua
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
