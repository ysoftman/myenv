-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 디폴트 키맵 https://www.lazyvim.org/keymaps
-- 현재 파일 reload
-- :so %

vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

-- LazyVim 기본 Alt+j/k 줄 이동을 Shift+Alt+j/k로 변경 (Zellij Alt+j/k 충돌 회피)
vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
vim.keymap.del("v", "<A-j>")
vim.keymap.del("v", "<A-k>")
vim.keymap.set("n", "<S-A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<S-A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<S-A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<S-A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<S-A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<S-A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- fzf-lua
-- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#commands
vim.keymap.set("n", "<a-r>", "<cmd>lua require('fzf-lua').registers()<CR>", { silent = true })
vim.keymap.set("n", "<a-t>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
vim.keymap.set("n", "<a-f>", "<cmd>lua require('fzf-lua').grep_cword()<CR>", { silent = true }) -- search word under cursor
vim.keymap.set("n", "<c-f>", "<cmd>lua require('fzf-lua').live_grep()<CR>", { silent = true }) -- live grep, 입력마다 rg 재실행하여 정확한 line:col 점프 유지
vim.keymap.set("n", "<c-l>", "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })

-- neotree
vim.keymap.set({ "n", "v" }, "<leader>tt", ":Neotree toggle reveal<cr>")
vim.keymap.set({ "n", "v" }, "<leader>tf", ":Neotree toggle reveal_force_cwd left<cr>")
-- vim.keymap.set({ "n", "v" }, "<leader>tf", ":Neotree source=filesystem reveal=true position=left<cr>")

-- comment
-- codelens 에서 해당 단축키를 사용하고 있다. 그냥 default gcc, gc 등을 사용하자.
-- vim.keymap.set({ "n", "v" }, "<leader>cc", function()
--   return require("vim._comment").operator()
-- end, { expr = true, desc = "Toggle comment" })

-- gen(ollama plugin)
vim.keymap.set({ "n", "v" }, "<leader>ga", ":Gen Ask<cr>", { desc = "Gen Ask" })
vim.keymap.set({ "v" }, "<leader>gr", ":Gen Review_Code<cr>", { desc = "Gen Review Code" })
vim.keymap.set({ "n", "v" }, "<leader>gm", ":lua require('gen').select_model()<cr>", { desc = "Gen Select Model" })

-- telescope
local telescope_builtin = require("telescope.builtin")
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
require("telescope").setup({
  defaults = {
    mappings = {
      i = { -- Insert mode mappings
        ["<c-j>"] = telescope_actions.move_selection_next, -- Move down
        ["<c-k>"] = telescope_actions.move_selection_previous, -- Move up
        ["<cr>"] = telescope_multiopen,
      },
    },
  },
})
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
