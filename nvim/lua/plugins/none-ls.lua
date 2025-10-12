return {
  {
    -- https://github.com/nvimtools/none-ls.nvim
    -- null-ls 유지보수 종료 후 개선된 버전
    -- formatting, diagnostics, code-actions, completion, hover 등을 지원
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
        nls.builtins.formatting.fish_indent,
        nls.builtins.diagnostics.fish,
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.prettier,
        nls.builtins.formatting.biome,
        nls.builtins.formatting.shfmt.with({
          -- conform shfmt 보다 none-ls shfmt 설정이 적용된다.
          -- use 4spaces instead of tabs(default)
          -- https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#printer-flags
          extra_args = { "-i", "4", "-ci" },
        }),
      })
    end,
  },
}
