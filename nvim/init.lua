-- vim plug 와 동시에 사용되지 않아 주석처리함
--require("config.lazy")

-- _init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)

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


-- [coc.nvim]: dyld[7087]: Library not loaded: Library not loaded: /opt/homebrew/opt/icu4c/lib/libicui18n.74.dylib
-- Referenced from: <3317C4D0-50F5-334B-8949-29926E34DA3C> /opt/homebrew/Cellar/node/22.9.0/bin/node 에러 발생시
--brew install icu4c node

-- K(:help) lua not found error 에러 발생시
--brew reinstall lua
--help
--:h lua-vim

-- 마우스 우클릭 메뉴 추가(gx 로 url 열기)
vim.cmd([[
amenu PopUp.Open\ in\ web\ browser  gx
]])

-- neovide (https://neovide.dev/configuration.html)
if vim.g.neovide then
    vim.o.guifont = "Hack Nerd Font:h18"
    vim.g.neovide_theme = 'auto'
    vim.g.neovide_scale_factor = 1.0
    vim.g.neovide_transparency = 1.0
    vim.g.neovide_show_border = true
    vim.g.neovide_theme = 'auto'
    vim.g.neovide_refresh_rate = 60
    vim.g.neovide_refresh_rate_idle = 5
    vim.g.neovide_no_idle = true
    vim.g.neovide_confirm_quit = true
    vim.g.neovide_cursor_animation_length = 0.12
    vim.g.neovide_cursor_trail_size = 0.3
    vim.g.neovide_cursor_vfx_mode = "railgun"
    --vim.g.neovide_cursor_vfx_mode = "torpedo"
    --vim.g.neovide_cursor_vfx_mode = "pixiedust"
    --vim.g.neovide_cursor_vfx_mode = "sonicboom"
    --vim.g.neovide_cursor_vfx_mode = "ripple"
    --vim.g.neovide_cursor_vfx_mode = "wireframe"
    vim.g.neovide_input_ime = true
    vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

    -- https://neovim.io/doc/user/lua.html#vim.keymap.set()
    --cmd-s 저장,  cmd-c/cmd-p 로 복붙하기
    vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
    vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
    vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
    vim.api.nvim_set_keymap('t', '<d-v>', '<C-\\><C-n>"+Pi', {noremap = true}) -- paste in terminal mode, fzf 사용시

    --  c--, c-=크기 조절 하기
    local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
    vim.keymap.set("n", "<C-=>", function()
        change_scale_factor(1.25)
    end)
    vim.keymap.set("n", "<C-->", function()
        change_scale_factor(1/1.25)
    end)

    -- neovide 에선 alt 대신 meta  키로 정의해야 동작함(.vimrc에서 <m-으로 설정해둠)
    --vim.keymap.set('n', '<m-f>', ':Rg2<CR>')
    --vim.keymap.set('n', '<m-t>', ':Files<CR>')
    --vim.keymap.set('n', '<m-m>', ':Marks<CR>')

    vim.print("neovide version: " .. vim.g.neovide_version .. ", settings are loaded.")
end
