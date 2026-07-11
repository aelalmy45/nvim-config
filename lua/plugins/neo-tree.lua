-- ~/.config/nvim/lua/plugins/neo-tree.lua
return {
  { "nvim-tree/nvim-tree.lua", enabled = false },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
      },
    },
  },
}
