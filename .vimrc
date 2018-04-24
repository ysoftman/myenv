"""""""""" ysoftman_settings_start
call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
Plug 'powerline/fonts'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'altercation/vim-colors-solarized'
Plug 'joshdick/onedark.vim'
Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.vim/plugged/fzf', 'do': './install --all' } 
Plug 'nathanaelkane/vim-indent-guides'
call plug#end()


" 사용자 설정
syntax on
color elflord
set number
set hlsearch
set backspace=indent,eol,start
set fencs=utf-8,cp949
set enc=utf-8
set tabstop=4
set autoindent
set laststatus=2
"set lines=80
set visualbell t_vb=
set list
set listchars=tab:→\ ,trail:·,precedes:«,extends:»,eol:¶
let g:go_version_warning = 0

syntax on
let g:onedark_termcolors=256
colorscheme onedark

set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" iterm -> non-ascii font 를 powerline 폰트로 변경 후 사용
let g:airline_powerline_fonts = 1

let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_enable_on_vim_startup = 1

" 단축키 설정
nmap <f1> :TagbarToggle<cr>¶
nmap <f4> :IndentGuidesToggle<cr>¶
nmap <f5> :GoRun<cr>¶
nmap <f7> :GoBuild<cr>¶
nmap <f12> :GoDef<cr>¶
nmap <s-f12> :GoCallees<cr>¶
nmap <c-f> :GoFmt<cr>¶
nmap <c-v> :GoVet<cr>¶
nmap <c-l> :GoLint<cr>¶
nmap <c-i> :GoImports<cr>¶
nmap <c-b> :NERDTreeToggle<cr>¶
nmap <c-t> :FZF<cr>¶

"""""""""" ysoftman_settings_end
