" vim-plug 설치(플러그인 매니저중 플러그인 설치 속도가 가장 빠름)
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

"플러그인 설치 vim 실행 후
":PlugInstall
":PlugUpdate
" 또는 터미널에서 플러그인 설치후 vim 종료
"vim +PlugInstall +qall

" vim 실행 후 GoInstallBinaries 로 $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
" dockerfile 로 이미지 빌드시 사용자 입력을 받을 수 없으니 slient 모드로 설치
"vim +'silent :GoInstallBinaries' +qall

"The ycmd server SHUT DOWN (restart with :YcmRestartServer)" 메시지가 발생하는 경우
"cd ~/.vim/plugged/youcompleteme/ && git submodule update --init --recursive
"./install.py
" youcompleteMe unavailable: requires Vim compiled with Python (3.6.0+) 메시지가 발생하는 경우
" python3 install.py --all

call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'preservim/nerdcommenter'
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
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'scrooloose/syntastic'
Plug 'altercation/vim-colors-solarized'
"colorizer 사용하면 파일 오픈시 autocmd BufEnter(버퍼로딩후 필요한 설정 처리) 단계에서 느려져서 사용하지 않음
"Plug 'lilydjwg/colorizer' " vim 으로 git 커밋 메세지 작성시 이슈번호 태깅을 위해 #123 를 사용하면 컬리 배경 표시~ㅎ
Plug 'joshdick/onedark.vim'
Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.vim/plugged/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'nathanaelkane/vim-indent-guides'
call plug#end()


" 사용자 설정
syntax on
color desert
set mouse=a
set number
"set relativenumber
set hidden
set hlsearch
set backspace=indent,eol,start
set fencs=utf-8,cp949
set enc=utf-8
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set laststatus=2
set showtabline=2
set ignorecase
"set lines=80
"set cursorcolumn
set cursorline
"set colorcolumn=100
set visualbell t_vb=
set listchars=tab:→\ ,space:·,trail:·,precedes:«,extends:»,eol:↵
"set nolist
set list
set timeoutlen=500

"let mapleader="\\"
let mapleader=","
let g:go_version_warning = 0
"nerdtree
let NERDTreeShowHidden=1

"nerdcommenter
filetype plugin on
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDToggleCheckAllLines = 1


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


"vim-multiple-cursors
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_word_key      = '<C-n>'
let g:multi_cursor_select_all_word_key = '<A-n>'
let g:multi_cursor_start_key           = 'g<C-n>'
let g:multi_cursor_select_all_key      = 'g<A-n>'
let g:multi_cursor_next_key            = '<C-n>'
let g:multi_cursor_prev_key            = '<C-p>'
let g:multi_cursor_skip_key            = '<C-x>'
let g:multi_cursor_quit_key            = '<Esc>'

"fzf
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
"Rg 창에 파일 이름 검색에서 제외
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

"space-vim-dark
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

"lightline 화살표 폰트가 없어 powerline 폰트가 필요 없다.
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
"buffer 표시를 위해선 lightline-bufferline 도 플러그인 설치 필요.
let g:lightline#bufferline#unnamed = '[No Name]'
let g:lightline#bufferline#show_number = 0
"let g:lightline#bufferline#modified = '✎'
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#enable_devicons = 1
"one 컬러로 변경해야 tabline 에 컬러가 반영된다.
let g:lightline.colorscheme = 'one'
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()


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

"커서라인 속성
"hi CursorLine cterm=underline ctermbg=darkgrey ctermfg=none
"Visual Block 컬러
hi Visual cterm=underline ctermbg=lightyellow

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


" mac 에선 기본적으로 option 키가 조합되면 특정 문자로 취급된다.
" option+a == å
" option+d == ∂
" option+p == π
" 사실 option 는 alt 와 다르고, 각 터미널에 따른 설정이 필요하다.
" iterm --> option 키 norml --> esc+
" kitty --> macos_option_as_alt no
" alacritty --> alt_send_esc: true 는 동작 하지 않는다.
" 아직 alt단축키마다 개별 설정이 필요하다.
" - { key: A, mods: Alt, chars: "\x1ba" }
" - { key: D, mods: Alt, chars: "\x1bd" }

" 단축키 설정
" timeout이 짧은 상태에서 일반 명령로 처리 될 수 있어 주의
noremap cj :clearjumps<enter>
noremap cw :cw<enter>
noremap co :copen<enter>
noremap cl :close<enter>
noremap sc :%s/<c-r><c-w>//gc<left><left><left>
noremap cfsc :cfdo %s///gc <bar> up<home><right><right><right><right><right><right><right><right>
noremap <c-j> :cn<enter>
"c-[ --> esc 라 사용하지 말자.
"noremap <c-[> :cp<enter>
noremap <c-k> :cp<enter>
noremap bn :bn<enter>
noremap bp :bp<enter>
noremap bd :bd<enter>
noremap bwo :%bwipeout <enter>
noremap sovim :source ~/.vimrc <enter>
"remove trailing whitespce
noremap rtw :%s/\s\+$//e<enter>
noremap <f1> :TagbarToggle<enter>
noremap <f4> :IndentGuidesToggle<enter>
noremap <c-b> :NERDTreeToggle<enter>
noremap <c-p><c-i> :PlugInstall<enter>
noremap <c-t> :FZF<enter>
noremap <c-h> :History<enter>
noremap <c-f> :Rg<enter>
noremap <c-l> :Buffers<enter>
"<c-m> <cr> --> 엔터 와 같아서 사용하지 않는다.
"noremap <c-m> :Maps<enter>
"[count]<leader>cc "선택한 라인 커멘트 설정
"[count]<leader>cu "선택한 라인 커멘트 해제
nnoremap <silent> <leader>c v:call NERDComment('x', 'toggle')<cr> "현재 라인 커멘트 토글

autocmd filetype c noremap <f5> :w <bar> :!clear; g++ % && ./a.out<enter>
autocmd filetype cpp noremap <f5> :w <bar> :!clear; g++ % && ./a.out<enter>

autocmd filetype go noremap <f5> :w <bar> :!clear; <enter> :GoRun<enter>
autocmd filetype go noremap <f7> :w <bar> :!clear; <enter> :GoBuild<enter>
autocmd filetype go noremap <leader>d :GoDef<enter>
"fuctionkey 조합은 동작 하지 않아 사용하지 않음.
"autocmd filetype go noremap <s-f12> :GoCallees<enter>
autocmd filetype go noremap <leader>c :GoCallees<enter>
autocmd filetype go noremap <leader>f :w <bar> :GoFmt<enter>
autocmd filetype go noremap <leader>i :w <bar> :GoImports<enter>
autocmd filetype go noremap <leader>g :GoGuruScope .<enter>
autocmd filetype go noremap <leader>v :GoVet<enter>:GoLint<enter>

