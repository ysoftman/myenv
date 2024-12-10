-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fr", builtin.registers, { desc = "Telescope registers" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<a-r>", builtin.registers, { desc = "Telescope registers" })
vim.keymap.set("n", "<a-t>", builtin.find_files, { desc = "Telescope find files" })
-- noice.nvim, scroll forward <c-f> 와 겹친다.(telescope > keys 에서 설정)
vim.keymap.set("n", "<c-f>", function()
  builtin.live_grep({
    prompt_prefix = "🔍",
    prompt_title = "Live Grep (Fuzzy)",
  })
end, { noremap = true, silent = true, desc = "Telescope Fuzzy Live Grep" })
-- lazyvim, go to left <c-l> 와 겹친다.(telescope > keys 에서 설정)
vim.keymap.set("n", "<c-l>", builtin.buffers, { desc = "Telescope buffers" })
