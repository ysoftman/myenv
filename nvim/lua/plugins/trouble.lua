return {
  -- https://github.com/folke/trouble.nvim
  -- 커맨드 사용예
  -- https://github.com/folke/trouble.nvim#commands
  -- :Trouble [mode] [action] [options]
  "folke/trouble.nvim",
  enabled = true,
  cmd = "Trouble",
  opts = {
    use_diagnostic_signs = true,
    modes = {
      -- 파일 찾기처럼 라인 정보 없는 커스텀한 quickfix
      -- 기본 qflist 모드는 라인 정보 없으면 [1,1])으로 파일당 2행이 생겨 이동이 번거로움
      -- 그룹 없이 파일 1개 = 1행으로 표시
      qffiles = {
        desc = "Quickfix Files",
        source = "qf.qflist",
        format = "{file_icon} {filename}",
      },
    },
  },
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false<cr>",
      desc = "Symbols (Trouble)",
    },
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    {
      "<leader>xL",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location List (Trouble)",
    },
    {
      "<leader>xQ",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix List (Trouble)",
    },
  },
}
