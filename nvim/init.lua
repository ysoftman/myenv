-- lazyvim
require("config.lazy")

--lazyvim 이후 .vimrc 설정이 덮어쓰여져서 단축키등의 설정이 동작안할 수 있다.
--vim plugin 은 사용할수 없어 .vimrc 에서 neovim 사용시 로딩 하지 않도록 했다.
--.vimrc 에서 공통 설정만 가져와 사용한다.
-- _init.vim(init.vim 역할) 로딩
local vimrc = vim.fn.stdpath("config") .. "/_init.vim"
vim.cmd.source(vimrc)

-- "olimorris/onedarkpro.nvim",
vim.cmd([[colorscheme tokyonight-night]])
-- vim.cmd("colorscheme onedark_vivid") -- zellij 와 같이 사용하면 배경이 갱신이 잘 안되는 문제가 있음(https://github.com/zellij-org/zellij/issues/3783)
vim.cmd("colorscheme onedark_dark")
-- vim.cmd("highlight Normal cterm=none guibg=none")
-- Visual Block 컬러
vim.cmd("hi Visual cterm=underline ctermbg=lightyellow guibg=yellow")
vim.cmd("highlight CursorLine guibg=#003f00")
-- popup menu selected item color
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#61afef", fg = "#282c34" })

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

-- https://neovim.io/doc/user/lua.html#vim.keymap.set()
--cmd-s 저장,  cmd-c/cmd-p 로 복붙하기
vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
-- mac command+c 가 시스템 레벨에서 복사 기능으로 할당되어 terminal neovim 으로 <D-c> 가 전달되지 못할 수있어 alt-c 로 사용
vim.keymap.set("v", "<M-c>", '"+y') -- Copy
vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
vim.keymap.set("v", "<D-v>", '"+P') -- Paste visual mode
vim.keymap.set("c", "<D-v>", "<C-R>+") -- Paste command mode
vim.keymap.set("i", "<D-v>", '<ESC>l"+Pli') -- Paste insert mode
vim.api.nvim_set_keymap("t", "<d-v>", '<C-\\><C-n>"+Pi', { noremap = true }) -- paste in terminal mode, fzf 사용시

-- neovide (https://neovide.dev/configuration.html)
if vim.g.neovide then
  vim.o.guifont = "Hack Nerd Font:h18"
  vim.g.neovide_theme = "auto"
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_transparency = 1.0
  vim.g.neovide_show_border = true
  vim.g.neovide_theme = "auto"
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
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"

  --  c--, c-=크기 조절 하기
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.25)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.25)
  end)

  -- neovide 에선 alt 대신 meta  키로 정의해야 동작함(.vimrc에서 <m-으로 설정해둠)
  --vim.keymap.set('n', '<m-f>', ':Rg2<CR>')
  --vim.keymap.set('n', '<m-t>', ':Files<CR>')
  --vim.keymap.set('n', '<m-m>', ':Marks<CR>')

  vim.print("neovide version: " .. vim.g.neovide_version .. ", settings are loaded.")
end
