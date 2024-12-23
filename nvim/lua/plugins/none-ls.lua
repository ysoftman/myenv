return {
  {
    "nvimtools/none-ls.nvim", -- for formatting, diagnostics, code-actions, completion, hover
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Add or modify sources here
        nls.builtins.formatting.prettier,
        nls.builtins.diagnostics.eslint,
        nls.builtins.formatting.shfmt.with({
          -- confirm shfmt 보다 none-ls shfmt 설정이 적용된다.
          -- use 4spaces instead of tabs(default)
          -- https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#printer-flags
          extra_args = { "-i", "4", "-ci" },
        }),
      })
    end,
  },
}
