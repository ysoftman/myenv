-- Conform.nvim은 Neovim에서 코드 포맷팅을 위한 플러그인입니다.
-- none-ls 의 포맷팅 기능과 충돌이 발생할 수 있다.
return {
  "stevearc/conform.nvim", -- For formatting
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>f",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Set default options
    default_format_opts = {
      async = false, -- not recommended to change
      quiet = false, -- not recommended to change
      lsp_format = "fallback", -- not recommended to change
    },
    -- Set up format-on-save
    -- Don't set `opts.format_on_save` for `conform.nvim`. **LazyVim** will use the conform formatter automatically
    -- format_on_save = {
    --   -- These options will be passed to conform.format()
    --   timeout_ms = 500,
    --   lsp_format = "fallback",
    -- },
    -- Customize formatters
    formatters = {
      prettier = {
        tabWidth = 2,
        singleQuote = true,
      },
      ["markdownlint-cli2"] = { command = "markdownlint" },
      shfmt = {
        -- use 4spaces instead of tabs(default)
        -- https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#printer-flags
        prepend_args = { "-i", "4", "-ci" },
      },
    },
    -- Define your formatters
    formatters_by_ft = {
      fish = { "fish_indent" },
      sh = { "shfmt" },
      markdown = { "prettier", "markdownlint-cli2" }, -- Specify formatters for Markdown
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettier" },
    },
  },
}
