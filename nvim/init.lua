--_init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)

--lazy plugin
--local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--if not vim.loop.fs_stat(lazypath) then
--  vim.fn.system({
--    "git",
--    "clone",
--    "--filter=blob:none",
--    "https://github.com/folke/lazy.nvim.git",
--    "--branch=stable", -- latest stable release
--    lazypath,
--  })
--end
--vim.opt.rtp:prepend(lazypath)

--vim plug 와 동시에 사용되지 않아 주석처리함
--require("lazy").setup("plugins")


-- telescope keymap
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

