-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 디폴트 키맵 https://www.lazyvim.org/keymaps
-- 현재 파일 reload
-- :so %

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fr", builtin.registers, { desc = "Telescope registers" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set({ "n", "v" }, "<a-r>", builtin.registers, { desc = "Telescope registers" })
vim.keymap.set({ "n", "v" }, "<a-t>", builtin.find_files, { desc = "Telescope find files" })
-- noice.nvim, scroll forward <c-f> 와 겹친다.
-- Search for a string and get results live as you type, respects .gitignore
vim.keymap.set({ "n", "v" }, "<c-f>", function()
  builtin.live_grep({
    prompt_title = "Live Grep (rg)",
  })
end, { noremap = true, silent = true, desc = "Telescope fuzzy live grep" })
-- Searches for the string under your cursor or the visual selection in your current working directory
vim.keymap.set({ "n", "v" }, "<a-f>", function()
  builtin.grep_string({
    prompt_title = "Grep String",
    shorten_path = true,
    only_sort_text = true,
    word_match = "-w",
  })
end, { noremap = true, silent = true, desc = "Telescope fuzzy grep string" })

-- lazyvim, go to left <c-l> 와 겹친다.
vim.keymap.set({ "n", "v" }, "<c-l>", builtin.buffers, { desc = "Telescope buffers" })

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
