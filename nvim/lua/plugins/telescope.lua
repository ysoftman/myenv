return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  },
  keys = {
    -- add a keymap to browse plugin files
    -- stylua: ignore
  },
  -- change some options
  opts = {
    defaults = {
      preview = true,
      layout_strategy = "vertical",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
      vimgrep_arguments = {
        "rg",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--fixed-strings", -- Treat all patterns as literals instead of as regular expressions. When this flag is used, special regular expression meta characters such as .(){}*+ should not need be escaped.
        -- "--hidden",
        "--smart-case", -- 소문자로만 입력시 대소문자 구분하지 않음, 아니면 대소문자 구분
        -- Add your custom rg options here
      },
    },
  },
}
