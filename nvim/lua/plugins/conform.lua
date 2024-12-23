-- Conform.nvim은 Neovim에서 코드 포매팅을 위한 플러그인입니다.
return {
  {
    "stevearc/conform.nvim", -- For formatting
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
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
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        markdown = { "prettier", "markdownlint-cli2" }, -- Specify formatters for Markdown
        javascript = { "prettier" },
        typescript = { "prettier" },
      },
    },
  },
}
