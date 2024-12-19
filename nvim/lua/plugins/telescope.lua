local telescope_actions = require("telescope.actions")
local telescope_action_state = require("telescope.actions.state")
local function telescope_multiopen(pb)
  local picker = telescope_action_state.get_current_picker(pb)
  local multi = picker:get_multi_selection()
  telescope_actions.select_default(pb) -- the normal enter behaviour
  for _, j in pairs(multi) do
    if j.path ~= nil then -- is it a file -> open it as well:
      vim.cmd(string.format("%s %s", "edit", j.path))
    end
  end
end

return {
  {
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
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<cr>"] = telescope_multiopen,
          },
        },
      },
    },
  },
}
