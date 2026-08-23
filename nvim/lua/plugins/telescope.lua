return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  },
  -- LazyVim telescope extra 의 디폴트 키들, 어느 픽커인지 알수 있게 desc 앞에 Telescope 를 붙인다
  keys = function(_, keys)
    for _, k in ipairs(keys) do
      if type(k) == "table" and type(k.desc) == "string" and not k.desc:match("^Telescope ") then
        k.desc = "Telescope " .. k.desc
      end
    end
    return keys
  end,
  -- change some options
  opts = function(_, opts)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    -- 단일 선택은 열고, 다중 선택은 Trouble 로 (fzf-lua 와 동일 동작)
    local function multiopen(pb)
      if #action_state.get_current_picker(pb):get_multi_selection() > 1 then
        return require("trouble.sources.telescope").open(pb)
      end
      actions.select_default(pb)
    end
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
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
      mappings = {
        i = { -- Insert mode mappings
          ["<c-j>"] = actions.move_selection_next, -- Move down
          ["<c-k>"] = actions.move_selection_previous, -- Move up
          ["<cr>"] = multiopen,
        },
      },
    })
  end,
}
