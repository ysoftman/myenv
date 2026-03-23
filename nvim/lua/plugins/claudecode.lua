return {
  -- https://github.com/coder/claudecode.nvim
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    terminal = {
      split_side = "bottom",
      split_width_percentage = 0.3,
      provider = "snacks",
    },
  },
  -- lazy.nvim에 키맵을 미리 등록하여 which-key에 표시되고,
  -- 해당 키 입력 시 플러그인이 자동으로 lazy-load 된다.
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>at", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
