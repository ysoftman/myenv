return {
  {
    "nvim-treesitter/nvim-treesitter", -- tree-sitter 기반의 syntax-highlighting, indentation..
    -- opts 속성을 사용하면 LazyVim이 자동으로 config 함수를 생성
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "gowork",
        "helm",
        "html",
        "javascript",
        "json",
        "kdl",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "zig",
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
          [".*nginx%.conf%.j2"] = "nginx",
        },
      })
    end,
  },
}
