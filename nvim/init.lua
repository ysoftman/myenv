--vim plug 와 동시에 사용되지 않아 주석처리함
--require("config.lazy")

--_init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)


-- neovide (https://neovide.dev/configuration.html)
if vim.g.neovide then
--vim.print(vim.g.neovide_version)
vim.o.guifont = "Hack Nerd Font:h16"
vim.g.neovide_scale_factor = 1.0
vim.g.neovide_transparency = 1.0
vim.g.neovide_show_border = true
vim.g.neovide_theme = 'auto'
vim.g.neovide_refresh_rate = 60
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_no_idle = true
vim.g.neovide_confirm_quit = true
vim.g.neovide_cursor_animation_length = 0.13
vim.g.neovide_cursor_trail_size = 0.3
vim.g.neovide_cursor_vfx_mode = "railgun"
--vim.g.neovide_cursor_vfx_mode = "wireframe"

end

-- telescope keymap
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
vim.keymap.set("n", "<leader>fr", builtin.registers, {})
--vim.keymap.set("n", "<a-t>", builtin.find_files, {})
--vim.keymap.set("n", "<c-f>", builtin.live_grep, {})
--vim.keymap.set("n", "<c-l>", builtin.buffers, {})
--vim.keymap.set("n", "<a-r>", builtin.registers, {})

--[coc.nvim]: dyld[7087]: Library not loaded: Library not loaded: /opt/homebrew/opt/icu4c/lib/libicui18n.74.dylib
--Referenced from: <3317C4D0-50F5-334B-8949-29926E34DA3C> /opt/homebrew/Cellar/node/22.9.0/bin/node 에러 발생시
--brew install icu4c node

--K (:help) lua not found error 에러 발생시
--brew reinstall lua
