--_init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)

