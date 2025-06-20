return {
  "nvim-neo-tree/neo-tree.nvim",
  -- LazyVim에서 plugin의 config 함수는 플러그인이 로드될 때 자동으로 실행
  config = function()
    require("neo-tree").setup({
      window = {
        mappings = {
          -- C-f 겹쳐서 비활성화(대소문자 구분)
          ["<C-f>"] = "",
          ["<C-b>"] = "",
        },
      },
    })
  end,
}
