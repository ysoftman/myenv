return {
  {
    -- https://github.com/mason-org/mason.nvim
    -- Mason은 Neovim에서 외부 도구(예: 언어 서버, 포매터, 린터)를 설치하고 관리하는 패키지 관리자입니다.
    -- :Mason 으로 설치 도구들 확인
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "black",
        "prettier",
        "biome",
        "marksman",
        "markdownlint",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "delve",
        "markdownlint-cli2",
        "markdown-toc",
        "ansible-lint",
        "ansible-language-server",
      },
      -- automatically install / update on startup. If set to false nothing
      -- will happen on startup. You can use :MasonToolsInstall or
      -- :MasonToolsUpdate to install tools and check for updates.
      -- Default: true
      run_on_start = true,
    },
  },
}
