require "nvchad.options"

-- add yours here!
vim.filetype.add({
  extension = {
    tcss = "css",
  },
})

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!
