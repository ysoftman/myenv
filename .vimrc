"""""""""" ysoftman_settings_start
call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
"Plug 'powerline/fonts'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
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
let g:lightline = {
      \ 'colorscheme': 'one',
      \ }

let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_enable_on_vim_startup = 1

" 단축키 설정
noremap <f1> :TagbarToggle<cr>
noremap <f4> :IndentGuidesToggle<cr>
noremap <f5> :GoRun<cr>
noremap <f7> :GoBuild<cr>
noremap <f12> :GoDef<cr>
noremap <s-f12> :GoCallees<cr>
noremap <f9> :GoFmt<cr>:GoImports<cr>
noremap <s-f9> :GoVet<cr>:GoLint<cr>
noremap <c-b> :NERDTreeToggle<cr>
noremap <c-t> :FZF<cr>

"""""""""" ysoftman_settings_end
