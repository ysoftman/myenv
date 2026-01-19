return {
  {
    -- Navigate your code with search labels, enhanced character motions and Treesitter integration
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      modes = {
        char = {
          enabled = false,
          -- f 로 찾을 문자로 포커스 이동하기
          keys = { "f", "F", "t", "T", ";", "," },
        },
      },
    },
    keys = {
      {
        -- s 로 찾을 단어로 포커스 이동하기
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}
