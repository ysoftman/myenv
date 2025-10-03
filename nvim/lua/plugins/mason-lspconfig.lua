-- mason.nvim 이 설치한 nvim-lspconfig 와 연결 및 설정 자동화
return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "lua_ls",
      "jsonls",
      "yamlls",
      "bashls",
      "helm_ls",
    },
    automatic_installation = true,
  },
}
