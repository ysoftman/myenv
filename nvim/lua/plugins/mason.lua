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
