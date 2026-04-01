return {
  {
    -- 단축키(키맵)를 시각적으로 탐색하고 기억하기 쉽게 도와주는 플러그인입니다.
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      -- which-key 팝업을 띄울 트리거 키를 지정합니다.
      triggers = {
        { "'", mode = "n" },
        { '"', mode = "n" },
        { "`", mode = "n" },
        { "<C-w>", mode = { "n", "t" } },
        { "<leader>", mode = { "n", "v" } },
        { "@", mode = "n" },
        { "[", mode = { "n", "v" } },
        { "]", mode = { "n", "v" } },
        { "c", mode = { "n", "v" } },
        { "g", mode = { "n", "v" } },
        { "z", mode = { "n", "v" } },
      },
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git/gen" }, -- add gen plugin
          { "<leader>gh", group = "hunks" },
          { "<leader>a", group = "claude code" },
          { "<leader>o", group = "opencode" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "gx", desc = "Open with system app" }, -- better descriptions
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },
}
