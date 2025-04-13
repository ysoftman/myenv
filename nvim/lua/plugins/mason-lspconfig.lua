return {
  "williamboman/mason-lspconfig.nvim",
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
