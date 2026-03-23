return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  -- lazy.nvim에 키맵을 미리 등록하여 which-key에 표시되고,
  -- 해당 키 입력 시 플러그인이 자동으로 lazy-load 된다.
  keys = {
    { "<leader>oa", mode = { "n", "x" }, desc = "Ask opencode" },
    { "<leader>ox", mode = { "n", "x" }, desc = "Execute opencode action…" },
    { "<leader>ot", mode = { "n", "t" }, desc = "Toggle opencode" },
    { "<leader>or", mode = { "n", "x" }, desc = "Add range to opencode" },
    { "<leader>ol", mode = "n", desc = "Add line to opencode" },
    { "<leader>ou", mode = "n", desc = "opencode half page up" },
    { "<leader>od", mode = "n", desc = "opencode half page down" },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- opencode keymaps (<leader>o 그룹)
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })

    vim.keymap.set({ "n", "t" }, "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "<leader>or", function()
      return require("opencode").operator("@this ")
    end, { expr = true, desc = "Add range to opencode" })

    vim.keymap.set("n", "<leader>ol", function()
      return require("opencode").operator("@this ") .. "_"
    end, { expr = true, desc = "Add line to opencode" })

    vim.keymap.set("n", "<leader>ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "opencode half page up" })

    vim.keymap.set("n", "<leader>od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "opencode half page down" })
  end,
}
