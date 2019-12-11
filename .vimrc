" vim-plug 설치(플러그인 매니저중 플러그인 설치 속도가 가장 빠름)
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

"플러그인 설치 vim 실행 후
":PlugInstall
" 또는 터미널에서 플러그인 설치후 vim 종료
"vim +PlugInstall +qall

" vim 실행 후 GoInstallBinaries 로 $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
" dockerfile 로 이미지 빌드시 사용자 입력을 받을 수 없으니 slient 모드로 설치
"vim +'silent :GoInstallBinaries' +qall

"The ycmd server SHUT DOWN (restart with :YcmRestartServer)" 메시지가 발생하는 경우
"cd ~/.vim/plugged/youcompleteme/ && git submodule update --init --recursive
"./install.py

call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
Plug 'itchyny/vim-gitbranch'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'glench/vim-jinja2-syntax'
Plug 'groenewege/vim-less'
Plug 'powerline/fonts'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'liuchengxu/space-vim-dark'
Plug 'flazz/vim-colorschemes'
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
color desert
set number
set hlsearch
set backspace=indent,eol,start
set fencs=utf-8,cp949
set enc=utf-8
set tabstop=4
set autoindent
set laststatus=2
"set lines=80
"set cursorcolumn
set cursorline
set colorcolumn=100
set visualbell t_vb=
set listchars=tab:→\ ,space:·,trail:·,precedes:«,extends:»,eol:↵
set nolist
" set list
let g:go_version_warning = 0


"vim-colors-solarized
let g:solarized_termtrans = 1
let g:solarized_termcolors=256
let g:solarized_contrast="high"
let g:solarized_visibility="high"
set background=dark

"vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1

" "space-vim-dark
" let g:space_vim_dark_background=234
" color space-vim-dark
" set termguicolors
" hi LineNr ctermbg=NONE guibg=NONE

"ondeark
" let g:onedark_termcolors=16
colorscheme onedark
let g:onedark_termcolors=256
" 컬러스킴 설정후 ColorColumn(colorcolumn) 값만 변경한다.
highlight ColorColumn ctermbg=brown

"lightline 화살표 폰트가 없어 powerline 폰트가 필요 없다
set laststatus=2
let g:lightline = {
\    'colorscheme': 'onedark',
\    'active': {
\        'left': [
\                [ 'mode', 'paste' ],
\                [ 'gitbranch', 'readonly', 'filename', 'modified' ]
\                ]
\    },
\    'component_function': {
\      'gitbranch': 'fugitive#head'
\    },
\}

"airline
" set laststatus=2
" let g:airline_theme='onedark'
" let g:airline_highlighting_cache=1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
" let g:airline#extensions#tabline#formatter = 'default'
" "iterm -> non-ascii font 를 powerline 폰트로 변경 후 사용
" let g:airline_powerline_fonts = 1

"vim-indent-guides
let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_enable_on_vim_startup = 1

"theme 적용 이후 커서라인 모양 설정해야함
"hi CursorLine cterm=underline ctermbg=NONE ctermfg=NONE

"vim-go
".go 파일에서 c-] , c-t 등 godef 관련 shortcut 이 아래 단축키 설정과 충돌해 비활성화
let g:go_def_mapping_enabled=0
" let g:go_fmt_command = "goimports"
" let g:go_fmt_autosave = 0
let g:go_highlight_structs = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" 단축키 설정
noremap <f1> :TagbarToggle<enter>
noremap <f4> :IndentGuidesToggle<enter>
noremap <f5> :GoRun<enter>
noremap <f7> :GoBuild<enter>
noremap <f12> :GoDef<enter>
noremap <s-f12> :GoCallees<enter>
noremap <f9> :GoFmt<enter>:GoImports<enter>
noremap <s-f9> :GoVet<enterr>:GoLint<enter>
noremap <c-b> :NERDTreeToggle<enter>
noremap <c-t> :FZF<enter>
"remove trailing whitespce
noremap rtw :%s/\s\+$//e<enter>
