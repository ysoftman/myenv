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

-- toggle list (공백 문자 표시). <leader>ul 은 LazyVim 기본 Line Number 토글이라 space 키 사용, Snacks.toggle 로 등록하면 which-key 메뉴에 자동 표시
Snacks.toggle.option("list", { name = "List Chars" }):map("<leader>u<space>")

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
