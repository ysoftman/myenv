return {
  "smoka7/multicursors.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvimtools/hydra.nvim",
  },
  opts = {},
  cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
  keys = {
    -- warn: 사용하고 나면 다음과 같은 에러가 발생하는 경우가 생김
    -- Recursion detected. Are you manually loading which-key in a keymap? Use opts.triggers instead. Please check the docs.
    {
      mode = { "v", "n" },
      "<Leader>m",
      "<cmd>MCstart<cr>",
      desc = "Create a selection for selected text or word under the cursor",
    },
  },
}
