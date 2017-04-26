syntax on
color elflord
set number
set hlsearch
set backspace=indent,eol,start
set fencs=utf-8,cp949
set tabstop=4
set autoindent
set laststatus=2

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
set tabstop=4
set autoindent
set laststatus=2

syntax on
let g:onedark_termcolors=256
colorscheme onedark

set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
" iterm -> non-ascii font 를 powerline 폰트로 변경 후 사용
" let g:airline_powerline_fonts = 1

let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
" let g:indent_guides_enable_on_vim_startup = 1
" :IndentGuidesToggle

" 단축키 설정
nmap <f5> :GoRun<cr>
nmap <f7> :GoBuild<cr>
nmap <c-i> :GoFmt<cr>
nmap <c-p> :GoImports<cr>
nmap <f12> :TagbarToggle<cr>
nmap <f10> :NERDTreeToggle<cr>
nmap <f3> :FZF<cr>
nmap <f4> :IndentGuidesToggle<cr>

"""""""""" ysoftman_settings_end
