return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    options = {
      always_show_bufferline = true,
      indicator = {
        -- icon = "▎", -- style =  "icon"일때
        icon = "✓",
        -- style = "underline",
        style = "icon",
      },
    },
  },
  keys = {
    { "<S-h>", false },
    { "<S-l>", false },
  },
}
