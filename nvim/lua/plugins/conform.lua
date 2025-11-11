return {
  -- https://github.com/stevearc/conform.nvim
  -- Conform.nvim은 Neovim에서 코드 포맷팅을 위한 플러그인입니다. mason 으로 설치된 formatter/linter 패키지들을 설정하고 실행한다
  -- none-ls 의 포맷팅 기능과 충돌이 발생할 수 있다.
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
      shfmt = {
        -- use 4spaces instead of tabs(default)
        -- https://github.com/mvdan/sh/blob/master/cmd/shfmt/shfmt.1.scd#printer-flags
        prepend_args = { "-i", "4", "-ci" },
      },
    },
    -- formatters by file type
    formatters_by_ft = {
      ["*"] = { "trim_whitespace" },
      cpp = { "clang-format" }, -- 프로젝트 루트 위치에 .clang-format 설정을 참고하게 된다. (https://github.com/ysoftman/test_code/blob/master/cpp/.clang-format)
      fish = { "fish_indent" },
      html = { "prettier" }, -- biome 가 아직 html 포맷팅은 안돼 prettier 사용
      javascript = { "biome" }, -- biome는 rust 로 만들어서 prettier 보다 성능이 좋다.(biome init 으로 biome.json 설정파일을 생성해 수정할 수 있다.)
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "biome" },
      json = { "biome" },
      jsonc = { "biome" },
      lua = { "stylua" },
      -- markdownlint 는 느림,  markdownlint-cli2 는 병렬 처리로 좀더 빠름
      markdown = { "markdownlint-cli2" },
      -- isort: import 문을 정렬, black: 전체 코드 스타일을 PEP 8에 따라 포맷
      python = { "isort", "black" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      typescript = { "biome" },
      -- typescript = { "prettier" },
      typescriptreact = { "biome" },
      -- yaml = { "yamlfmt" }, -- ansible yaml 도 포맷하기 때문에 확장자로 yamlfmt 을 사용하지 않기로 함
      toml = { "taplo" },
    },
  },
}
