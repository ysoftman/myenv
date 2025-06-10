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
        "c",
        "cpp",
        "rust",
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
          --  % 는 특수문자를 escape 하기 위한 lua 정규식 표현
          [".*/templates/.*%.ya?ml"] = "helm",
          ["helmfile.*%.ya?ml"] = "helm",
          [".*%.tpl"] = "helm",
        },
      })
    end,
  },
}
