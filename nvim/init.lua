--vim plug 와 동시에 사용되지 않아 주석처리함
--require("config.lazy")

--_init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)


-- telescope keymap
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fr", builtin.registers, {})
