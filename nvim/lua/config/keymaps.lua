-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 디폴트 키맵 https://www.lazyvim.org/keymaps
-- 현재 파일 reload
-- :so %

vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

-- fzf-lua
-- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#commands
vim.keymap.set("n", "<a-r>", "<cmd>lua require('fzf-lua').registers()<CR>", { silent = true })
vim.keymap.set("n", "<a-t>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<a-f>", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true }) -- search word under cursor
vim.keymap.set("n", "<c-f>", "<cmd>lua require('fzf-lua').grep({search=''})<CR>", { silent = true }) -- search pattern, search 옵션이 없으면 input_prompt 가 뜬다.
vim.keymap.set("n", "<c-l>", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })

-- neotree
vim.keymap.set({ "n", "v" }, "<leader>tt", ":Neotree toggle reveal<cr>")
vim.keymap.set({ "n", "v" }, "<leader>tf", ":Neotree toggle reveal_force_cwd<cr>")

-- lsp
local lsp_keys = require("lazyvim.plugins.lsp.keymaps").get()
-- gd, gr 로 사용하는데 다음도 추가
lsp_keys[#lsp_keys + 1] = { "<leader>d", vim.lsp.buf.definition, desc = "Go to Definition" }
lsp_keys[#lsp_keys + 1] = { "<leader>r", vim.lsp.buf.references, desc = "Go to References" }

-- comment
-- codelens 에서 해당 단축키를 사용하고 있다. 그냥 default gcc, gc 등을 사용하자.
-- vim.keymap.set({ "n", "v" }, "<leader>cc", function()
--   return require("vim._comment").operator()
-- end, { expr = true, desc = "Toggle comment" })

-- telescope
local telescope_builtin = require("telescope.builtin")
local telescope_actions = require("telescope.actions")
local telescope_action_state = require("telescope.actions.state")
require("telescope").setup({
  defaults = {
    mappings = {
      n = { -- Normal mode mappings
        ["t"] = require("telescope.actions").move_selection_next, -- Move down
        ["c"] = require("telescope.actions").move_selection_previous, -- Move up
      },
      i = { -- Insert mode mappings
        ["<C-j>"] = require("telescope.actions").move_selection_next, -- Move down
        ["<C-k>"] = require("telescope.actions").move_selection_previous, -- Move up
      },
    },
  },
})
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
vim.keymap.set("i", "<cr>", telescope_multiopen, { desc = "Telescope open multiple files" })
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fr", telescope_builtin.registers, { desc = "Telescope registers" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Telescope live grep" })
-- ctrl, alt 조합 단축키들은 fzf-lua 로 사용
-- vim.keymap.set({ "n", "v" }, "<a-r>", telescope_builtin.registers, { desc = "Telescope registers" })
-- vim.keymap.set({ "n", "v" }, "<a-t>", telescope_builtin.find_files, { desc = "Telescope find files" })
-- Searches for the string under your cursor or the visual selection in your current working directory
-- vim.keymap.set({ "n", "v" }, "<a-f>", function()
--   telescope_builtin.grep_string({
--     prompt_title = "Grep String",
--     shorten_path = true,
--     only_sort_text = true,
--     word_match = "-w",
--   })
-- end, { noremap = true, silent = true, desc = "Telescope fuzzy grep string" })
-- noice.nvim, scroll forward <c-f> 와 겹친다.
-- Search for a string and get results live as you type, respects .gitignore
-- vim.keymap.set({ "n", "v" }, "<c-f>", function()
--   telescope_builtin.live_grep({
--     prompt_title = "Live Grep (rg)",
--   })
-- end, { noremap = true, silent = true, desc = "Telescope fuzzy live grep" })
