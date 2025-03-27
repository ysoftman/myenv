-- Mason은 Neovim에서 외부 도구(예: 언어 서버, 포매터, 린터)를 설치하고 관리하는 패키지 관리자입니다.
-- :Mason 으로 설치 도구들 확인
return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "gomodifytags", "impl" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "delve" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "markdownlint-cli2", "markdown-toc" } },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "ansible-lint", "ansible-language-server" } },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      -- a list of all tools you want to ensure are installed upon
      -- start
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "black",
        "prettier",
        "marksman",
        "markdownlint",
      },
      -- automatically install / update on startup. If set to false nothing
      -- will happen on startup. You can use :MasonToolsInstall or
      -- :MasonToolsUpdate to install tools and check for updates.
      -- Default: true
      run_on_start = true,
    },
  },
}
