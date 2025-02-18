return {
  {
    "nvim-treesitter/nvim-treesitter", -- tree-sitter 기반의 syntax-highlighting, indentation..
    -- opts 속성을 사용하면 LazyVim이 자동으로 config 함수를 생성
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "helm",
        "gotmpl",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "kdl",
        "toml",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
      })
      vim.filetype.add({
        pattern = {
          [".*/templates/.*%.ya?ml"] = "helm",
          ["helmfile.*%.ya?ml"] = "helm",
        },
      })
    end,
  },
}
