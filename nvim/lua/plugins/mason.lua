-- Mason은 Neovim에서 외부 도구(예: 언어 서버, 포매터, 린터)를 설치하고 관리하는 패키지 관리자입니다.
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
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "black",
        "prettier",
        "marksman",
        "markdownlint",
      },
      formatters_by_ft = {
        ["html"] = { "prettier" },
        ["markdown"] = { "prettier", "markdownlint" },
        ["lua"] = { "stylua" },
        ["py"] = { "black" },
      },
    },
  },
}
