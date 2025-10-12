return {
  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- LSP(Language Server Protocol)를 설치하고 nvim-lspconfig(에서는 lsp 수동 설치) 와 연결 및 설정 자동화
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
