return {
  "folke/trouble.nvim",
  enabled = true,
  opts = {
    multiline = true,
    use_diagnostic_signs = true,
    modes = {
      diagnostic = {
        auto_open = true,
        auto_preview = true,
      },
    },
  },
  keys = {
    {
      mode = { "n" },
      "<leader>tr",
      "<cmd>Trouble<cr>",
      desc = "Trouble",
    },
  },
}
