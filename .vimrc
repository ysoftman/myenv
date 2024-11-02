"기본 설정
syntax on
color desert
set mouse=a
set number
"set relativenumber
set hidden
set hlsearch
set incsearch
"set autoread
set backspace=indent,eol,start
set fencs=utf-8,cp949
set maxmempattern=10000 "Maximum amount of memory (in Kbyte) to use for pattern matchin
set enc=utf-8
set tabstop=4
set shiftwidth=4
set expandtab "tab키 입력시 tabstop설정된 값만큼 스페이스 사용
set autoindent "붙여넣기시에는 :set paste 사용
set laststatus=2
set showtabline=2
set showcmd
set updatetime=1000 "화면 갱신 주기(default: 4000ms), 커서 사용중일때는 갱신 안함
set signcolumn=yes
set ignorecase
"set lines=80
"set cursorcolumn
set cursorline
"set colorcolumn=100
"set iskeyword=@,48-57,_,-,192-255,# "설정된 문자로 연결되면 하나의 워드로 취급
set iskeyword+=- "워드로 취급문자에 - 도 추가
set visualbell t_vb=
" eol까지 표시하면 너무 verbose 하게 표시되는것 같음
"set listchars=tab:→\ ,space:·,trail:·,precedes:«,extends:»,eol:↵
set listchars=tab:→\ ,space:·,trail:·,precedes:«,extends:»
"커서라인 속성
"hi CursorLine cterm=underline ctermbg=darkgrey ctermfg=none
"set nolist
set list
"mapping 입력 완료 타임아웃(ttimeoutlen<0이면, keycode(<esc><enter><up><down>..등)도해당)
set timeoutlen=1000
"keycode 입력 완료 타임아웃
set ttimeoutlen=50
"수직창 구분선 기본| 대신 │사용하여 끊김없이 보기(set enc=utf-8)
set fillchars=vert:\│
"let mapleader="\\"
let mapleader=","
" let variable 확인시
":echo mapleader
":let mapleader

" 단축키 설정
" mac 에선 기본적으로 alt/meta/option 키가 조합되면 특정 문자로 취급된다.
" option+a == å
" option+d == ∂
" option+p == π
" 각 터미널에 따른 설정이 필요하다.
" iterm --> option 키 normal --> esc+
" kitty --> macos_option_as_alt no
" alacritty
" --> alt_send_esc: true 는0.12.0 에서 디폴트로 설정에서 제거됨
" --> windows > option_as_alt: Both 로 설정함
" :h key-notation 참고
" timeout이 짧은 상태에서 일반 명령로 처리 될 수 있어 주의
" nnoremap 에 h j k l 등으로 시작하게 되면 커서 사용시 timeoutlen 만큼 기다린 후
" 마지막 동작이 수행 되기 때문에 사용하지 않도로 한다.

" vim 에서 alt 조합이 안되서 설정
" nvim 에서는 필요없는데 unknown option error 발생해 nvim feature 가 없을때만 수행
if !has('nvim')
    " alt + h,j,k,l 은 zellij 에서 MoveFocus 로 사용하고 있음
    execute "set <a-i>=\ei"
    execute "set <a-o>=\eo"
    execute "set <a-f>=\ef"
    execute "set <a-t>=\et"
    execute "set <a-m>=\em"
    execute "set <a-p>=\ep"
endif

" quickfix list 에서 사용할 단축키
nnoremap <leader>cj :clearjumps<enter>
nnoremap <leader>cw :cw<enter>
nnoremap <leader>co :copen<enter>
nnoremap <leader>ccl :cclose<enter>
"c-[ --> esc 라 사용하지 말자.
"nnoremap <c-[> :cp<enter>
nnoremap <c-k> :cp<enter>
nnoremap <c-j> :cn<enter>
" quickfix list 에서 replace (편의를 위해 입력위치로 커서 이동)
nnoremap cfsc :cfdo %s///gc <bar> up<home><right><right><right><right><right><right><right><right>
" location list 에서 사용할 단축키
" l 로 시작하면 오른쪽 방향키(l)일때 액션이 timeoutlen 만큼 지연되서 사용하지 않음
nnoremap <leader>lo :lopen<enter>
nnoremap <leader>lcl :lclose<enter>
nnoremap <leader>k :lprev<enter>
nnoremap <leader>j :lnext<enter>
" buffer 관련 단축키
nnoremap bn :bn<enter>
nnoremap bp :bp<enter>
nnoremap bd :bd<enter>
nnoremap bwo :%bwipeout<enter>
" buffer 파일들 다시 로딩
" bufdo 를 사용하면 syntax highlighting 등이 동작하지 않는다
"nnoremap be :bufdo e<enter>
" format json file
nnoremap sjq :%!jq .<enter>
" format xml file, 포맷팅 후 에러 메시지가 추가될 수 있다.
nnoremap <leader>xml :%!xmllint --format -<enter>
" remove trailing whitespace
nnoremap rtw :%s/\s\+$//e<enter>
" .vimrc 다시 적용
nnoremap sovim :source ~/.vimrc<enter>
" replace (편의를 위해 입력위치로 커서 이동)
nnoremap sc :%s/<c-r><c-w>//gc<left><left><left>
" c-a 는 커서에서 공백 구분되는 단어
nnoremap sC :%s/<c-r><c-a>//gc<left><left><left>
" 패턴이 포함된 모든 라인 삭제
nnoremap sgd :g/<c-r><c-w>/d
" word cout
nnoremap swc :%s/<c-r><c-w>//gn
" zellij ctrl-o(session), alt-i, alt-o 는 빌활성화 해뒀음
nnoremap <a-i> <c-i>
nnoremap <a-o> <c-o>
" tab -> space 변경
nnoremap retab :set expandtab<enter>:retab<enter>
" space -> tab 변경
nnoremap retab! :set noexpandtab<enter>:retab!<enter>:set expandtab<enter>
" window pane 이동
nnoremap <s-up> <c-w>k
nnoremap <s-down> <c-w>j
nnoremap <s-left> <c-w>h
nnoremap <s-right> <c-w>l

autocmd filetype javascript setlocal tabstop=2 shiftwidth=2
autocmd filetype json setlocal tabstop=2 shiftwidth=2 foldmethod=syntax nofoldenable
autocmd filetype xml setlocal tabstop=2 shiftwidth=2
autocmd filetype conf setlocal nofoldenable
autocmd BufNewFile,BufRead * if expand('%:t') =~ 'caddyfile' | setlocal tabstop=2 shiftwidth=2 noexpandtab | endif
autocmd BufNewFile,BufRead ~/.config/cava/config set filetype=confini
autocmd BufNewFile,BufRead *.yaml.tpl set filetype=yaml

"" 여기까지만 nvim 에서 로딩하도록 한다.
"if has('nvim')
"    finish
"endif


"vim-plug 설치(플러그인 매니저중 플러그인 설치 속도가 가장 빠름)
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

"플러그인 설치 vim 실행 후
":PlugInstall
":PlugUpdate
"또는 터미널에서 플러그인 설치후 vim 종료
"vim +PlugInstall +qall

"vim 실행 후 GoInstallBinaries 로 $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
"dockerfile 로 이미지 빌드시 사용자 입력을 받을 수 없으니 silent 모드로 설치
"vim +'silent :GoInstallBinaries' +qall

"The ycmd server SHUT DOWN (restart with :YcmRestartServer) 메시지가 발생하는 경우
"cd ~/.vim/plugged/youcompleteme/ && git submodule update --init --recursive && ./install.py --all --verbose

"FileNotFoundError: [Errno 2] No such file or directory: '/Users/ysoftman/.vim/plugged/youcompleteme/third_party/ycmd/third_party/go/bin/gopls' 에러 발생하는 경우
"cd ~/.vim/plugged/youcompleteme/third_party/ycmd/
"git checkout master
"git pull
"git submodule update --init --recursive
"./build.py --go-completer --verbose

"YouCompleteMe unavailable: requires Vim compiled with Python (3.6.0+) support. 메시지가 발생하는 경우
"vim 에 +python3 로 설치되었는 확인 후 없으면(-python3) myenv/installvim.sh 로 소스빌드로 설치
"vim --version | grep -i python
"그래도 안되면, python3 으로 다시 YouCompleteMe 빌드
"~/.vim/plugged/youcompleteme/install.py --all --verbose

call plug#begin('~/.vim/plugged')
"Plug 'flazz/vim-colorschemes' " colorscheme joshdick/onedark.vim 와 vim-colorschemes 충돌
"Plug 'kien/ctrlp.vim' " ctrlp 는 fuzzfile,buffer... 인데 fzf 가 더 좋은것 같아 굳이 사용할 필요없어 보임
"Plug 'lilydjwg/colorizer' " vim 으로 git 커밋 메세지 작성시 이슈번호 태깅을 위해 #123 를 사용하면 컬리 배경 표시, 그런데 colorizer 사용하면 파일 오픈시 autocmd BufEnter(버퍼로딩후 필요한 설정 처리) 단계에서 느려져서 사용하지 않음
"Plug 'vim-airline/vim-airline' "statusline pluging
"Plug 'vim-airline/vim-airline-themes' "colorscheme
"Plug 'vim-syntastic/syntastic' "This project is no longer maintained
Plug 'airblade/vim-gitgutter' "git diff
Plug 'altercation/vim-colors-solarized' "colorscheme
Plug 'alvan/vim-closetag' "html tag auto close
Plug 'davidhalter/jedi-vim' "python autocompletion
Plug 'dense-analysis/ale' "asynchronous lint, syntastic alternative
Plug 'fatih/vim-go' "go development plugin
Plug 'glench/vim-jinja2-syntax' "jinja2 template syntax
Plug 'groenewege/vim-less' "dynamic stylesheet language
Plug 'itchyny/lightline.vim' "statusline/tabline plugin
Plug 'itchyny/vim-gitbranch' "git branch name for lightline
Plug 'jiangmiao/auto-pairs' "[](){}\"\"''``<> , html 태그는 vim-closetag 로 처리
Plug 'johngrib/vim-game-code-break' "bricks breaker game
Plug 'joshdick/onedark.vim' "colorscheme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } "fuzzy-finder:files,command,history,bookmarks
Plug 'junegunn/fzf.vim' "fzf for vim
Plug 'junegunn/vim-emoji' "fzf emoji
Plug 'liuchengxu/space-vim-dark' "colorscheme
Plug 'majutsushi/tagbar' "browse the tags of the current file and get overview of its structure
Plug 'markonm/traces.vim' "preview for :substitute, %s/aa/bb/gc 실행정 미리변경된 결과 보기
Plug 'maxmellon/vim-jsx-pretty' "react syntax highlighting and indentin
Plug 'mengelbrecht/lightline-bufferline' "butterline,tabline functionality for lightline
Plug 'nathanaelkane/vim-indent-guides' "display indent level
Plug 'neoclide/coc.nvim', {'branch': 'release'} "language server, just use for json, ts
Plug 'octol/vim-cpp-enhanced-highlight' "syntax highlight for c++
Plug 'pangloss/vim-javascript' "syntax highlighting and indentation
Plug 'powerline/fonts' "font, using in airline
Plug 'preservim/nerdcommenter' "comment functions
Plug 'preservim/nerdtree' "browse directory and open files
Plug 'psf/black' "python code formatter
Plug 'rust-lang/rust.vim' "rust development plugin
Plug 'ryanoasis/vim-devicons' "icons
Plug 'sheerun/vim-polyglot' "A collection of language syntax highlighting(ex) c++, go, nginx, helm, sh, toml, git config, etc...)
Plug 'terryma/vim-multiple-cursors' "multiple selection and edit
Plug 'tpope/vim-abolish' "Abbreviation, snake_case, camelCase, UPPER_CASE, dash-case, dot.case
Plug 'tpope/vim-fugitive' "git command
Plug 'valloric/youcompleteme' "code completion engine
if has('nvim')
    Plug 'nvim-lua/plenary.nvim' "lua functions, using in telescope,neo-tree
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' } "similar to fzf
endif
call plug#end()

"Plug
nnoremap <leader>pi :PlugInstall<enter>

"tags 파일생성
nnoremap <leader>ct :!ctags -R
            \ --exclude=min
            \ --exclude=vendor
            \ --exclude=\*.min.\*
            \ --exclude=\*.map
            \ --exclude=\*.swp
            \ --exclude=\*.bak
            \ --exclude=tags
            \ --exclude=node_modules
            \ --exclude=static
            \ --exclude=coverage
            \ --exclude=bower_components
            \ --exclude=test
            \ --exclude=tests
            \ --exclude=__test__
            \ --exclude=.git
            \ --exclude=build
            \ --exclude=dist
            \ --exclude="*.bundle.*"
            \ --exclude="*.un~*"<enter>
"tags 생성후
"Ctrl-] Jump to the tag underneath the cursor
":ts <tag> <RET> Search for a particular tag
":tn Go to the next definition for the last tag
":tp Go to the previous definition for the last tag
":ts List all of the definitions of the last tag
"Ctrl-t Jump back up in the tag stack

"vim-jsx-pretty
let g:vim_jsx_pretty_colorful_config = 1

"auto-pairs
au FileType html let b:AutoPairs = ({'<!--' : '-->'})
" 빈값을 두면 해당 기능은 비활성화
let g:AutoPairsShortcutToggle = '<a-p>'

"vim-closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx'

"nerdtree
let NERDTreeFileLines=0  "활성화 하면 느려짐
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.swp$', '\.o$']
nnoremap <leader>tt :NERDTreeToggle<enter>
"선택한 파일위치로 자동 포커스 된다.
nnoremap <leader>tf :NERDTreeFind<enter>
" nerdtree 창만 남은 경우에 nerdtree 창 종료 없이 바로 vim 종료할 수 있도록 함
" 그런데 열려 있는 버퍼가 있는데도 종료하는 경우가 있어 사용하지 않음
"autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
"nerdtree 창에 다른 내용이 열리지 않도록 방지
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_tab_\d\+' && bufname('%') !~ 'NERD_tree_tab_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

"nerdcommenter
"[count]<leader>cc 선택한 라인 커멘트 설정
"[count]<leader>cu 선택한 라인 커멘트 해제
"현재 라인 커멘트 토글
nnoremap <silent> <leader>c v:call nerdcommenter#Comment('x', 'toggle')<cr>
filetype plugin on
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDToggleCheckAllLines = 1

"tagbar
nnoremap <f1> :TagbarToggle<enter>

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

"space-vim-dark
" let g:space_vim_dark_background=234
" color space-vim-dark
" set termguicolors
" hi LineNr ctermbg=NONE guibg=NONE

"ondeark
colorscheme onedark
"let g:onedark_termcolors=16
let g:onedark_termcolors=256
" 컬러스킴 설정후 ColorColumn(colorcolumn) 값만 변경한다.
highlight ColorColumn ctermbg=brown
" color terminal background 색상은 설정 안하기(검은색으로 보임)
highlight Normal ctermbg=none
"Visual Block 컬러
hi Visual cterm=underline ctermbg=lightyellow

"vim-colors-solarized
"let g:solarized_termtrans = 1
"let g:solarized_termcolors=256
"let g:solarized_contrast="high"
"let g:solarized_visibility="high"
"set background=dark

"if !has('nvim')
"lightline
"화살표 폰트가 없어 powerline 폰트가 필요 없다.
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
\      'gitbranch': 'gitbranch#name'
\    },
\}
"lightline-bufferline
"buffer 표시를 위해 설치.
let g:lightline#bufferline#unnamed = '[No Name]'
let g:lightline#bufferline#show_number = 0
let g:lightline#bufferline#modified = '✎'
let g:lightline#bufferline#unicode_symbols = 1
let g:lightline#bufferline#enable_devicons = 1
"one 컬러로 변경해야 tabline 에 컬러가 반영된다.
let g:lightline.colorscheme = 'one'
let g:lightline.tabline          = {'left': [['buffers']], 'right': [['close']]}
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()
"endif


"airline
" set laststatus=2
" let g:airline_theme='onedark'
" let g:airline_highlighting_cache=1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '|'
" let g:airline#extensions#tabline#formatter = 'default'
" iterm2 -> non-ascii font 를 powerline 폰트로 변경 후 사용
" let g:airline_powerline_fonts = 1

"ale
":ALEInfo "현재 설정값 보기
":ALEEnable
":ALEDisable
" brew install shellcheck
let g:ale_enabled=1
"ale_linters 는 아래 처럼 별도 설정하지 않으면 디폴트로 파일별 미리 정해진 linter 가 설정된다.
"vim-go 와 달리 linter 커맨드를 입력하지 않아도 golangci-lint 결과가 코드에 자동으로 표시된다
let g:ale_linters = {
\ 'python': ['flake8', 'pylint'],
\ 'javascript': ['eslint'],
\ 'go': ['golangci-lint', 'gofmt'],
\ 'rust': ['analyzer', 'rustc'],
\ 'sh': ['shellcheck'],
\}
" yarn global add eslint prettier 로 실행될 수 있어야 한다.
" prettier 에서 helm template 이슈가 있어 yaml 은 사용하지 않는다.
" https://github.com/prettier/prettier/issues/6517
let g:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
"\ 'yaml': ['prettier'],
\ 'markdown': ['prettier'],
\ 'json': ['prettier', 'trim_whitespace'],
\ 'typescript': ['prettier', 'eslint', 'trim_whitespace'],
\ 'javascript': ['prettier', 'eslint', 'trim_whitespace'],
\ 'css': ['prettier', 'trim_whitespace'],
\ 'scss': ['prettier', 'trim_whitespace'],
\ 'html': ['prettier', 'trim_whitespace'],
\}
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1
" pylint 가 설치되어 있는데, pylint 사용시 너무 verbose 해서 사용하지 않음
let g:ale_linters_ignore = {'python':['flake8','pylint']}

"vim-indent-guides
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
hi IndentGuidesOdd  ctermbg=none
hi IndentGuidesEven ctermbg=darkgrey
nnoremap <f4> :IndentGuidesToggle<enter>

"coc
":h coc-nvim  "for help
":CocInstall coc-json coc-tsserver coc-rust-analyzer "install coc extention or configure language server(LSP)
":CocConfig  "open coc-settings.json
" GoTo code navigation
let g:coc_start_at_startup = 1
nmap <silent> <leader>d <Plug>(coc-definition)
nmap <silent> <leader>y <Plug>(coc-type-definition)
nmap <silent> <leader>i <Plug>(coc-implementation)
nmap <silent> <leader>r <Plug>(coc-references)
" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)

"fzf
"FZF_DEFAULT_COMMAND 설정에 의존, hidden 파일검색 되도록 myenv.sh 설정되어 있다.
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
"찾기
command! -bang -nargs=* Rg1 call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
"현재 커서에 있는 워드 패턴으로 찾기
command! -bang -nargs=* Rg2 call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(expand('<cword>')), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
".gitignore, 숨김 내용도 찾기
command! -bang -nargs=* Rg3 call fzf#vim#grep("rg --no-ignore --hidden --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
":W 로 :Windows 가 실행되는것을 방지
command! -nargs=* W w
" zellij ctrl-t(tab), ctrl-h(move), alt-h,alt-j,alt-k,alt-l(포커스이동)등의 단축키와 중복되지 않도록 단축키를 추가한다.
nnoremap <c-f> :Rg1<enter>
nnoremap <a-f> :Rg2<enter>
" uppercase 로 시작해야 하는 사용자 지정 커맨드를 소문자로 사용하기 위해서
" command line 모드에서 rg로 시작하는 문자로 매핑( / 찾기 커맨드에서도 치환되니 참고)
cnoreabbrev rg1 :Rg1
cnoreabbrev rg2 :Rg2
cnoreabbrev rg3 :Rg3
nnoremap <c-l> :Buffers<enter>
"insert 모드에서 ctrl+v숫자 (터미널로 입력되는 특수키 문자 파악, 예를 들어 숫자에 027입력하면 ^[ --> ESC 키로 ^와[ 를 조합된게 아님, 065는 A로 표시된다)
"ctl+v후 alt+t 입력하면 ==> t 문자가 된다.
"하지만  는 esc 문자라 esc후t를 눌러도 동작하게 되는 문제가 있다.
"nnoremap t :Files<enter>
nnoremap <c-t> :Files<enter>
nnoremap <a-t> :Files<enter>
"ctrl-m == <cr>(enter) 같아서 enter 키로도 수행되는 문제가 있다.
"nnoremap <c-m> :Marks<enter>
nnoremap <a-m> :Marks<enter>
nnoremap <c-h> :History<enter>
"<leader>h 로 시작하는 단축키와 충돌들 피하기 위해 hh 두번 사용
nnoremap <leader>hh :History<enter>
" 새로운 커맨드 실행을 위해서 History 창에서 기존 커맨드를 수정해야 하는 번거로움이 있다.
nnoremap <leader>: :History:<enter>
" 새로운 찾기를 하려면 기존 히스토리를 수정해야 하는 번거로움이 있다.
nnoremap <leader>/ :History/<enter>
nnoremap <leader>cmd :Commands<enter>
nnoremap <leader>m :Maps<enter>

"vim-gitgutter
let g:gitgutter_set_sign_backgrounds = 1
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange guifg=#bbbb00 ctermfg=3
highlight GitGutterDelete guifg=#ff2222 ctermfg=1
let g:gitgutter_sign_added              = '+'
let g:gitgutter_sign_modified           = '~'
let g:gitgutter_sign_removed            = '-'
let g:gitgutter_sign_removed_first_line = '-‾'
let g:gitgutter_sign_removed_above_and_below = '-¯'
let g:gitgutter_sign_modified_removed   = '~-'
":GitGutter              Update signs for the current buffer.  You shouldn't need to run this.
":GitGutterAll           Update signs for all buffers.  You shouldn't need to run this.

"vim.emoji
"insert 모드에서:입력하다 ctrl+x ctrl+u 하면 자동완성 리스트가 보이고 선택.
set completefunc=emoji#complete

"vim-fugitive
nnoremap <leader>gs :Git<enter> "opens summary window
nnoremap <leader>gd :Git diff<enter>
nnoremap <leader>gl :Git log<enter>
nnoremap <leader>ga :Git add %<enter>
nnoremap <leader>gc :Git commit<enter>
nnoremap <leader>gp :Git push<enter>
nnoremap <leader>gb :Git blame<enter>

" vim-abolish
"MixedCase (crm)
"camelCase (crc)
"snake_case (crs)
"UPPER_CASE (cru)
"dash-case (cr-)
"dot.case (cr.)
"space case (cr<space>)
"Title Case (crt)

"c/cpp
autocmd filetype c nnoremap <f5> :w <bar> :!clear; g++ % && ./a.out<enter>
autocmd filetype cpp nnoremap <f5> :w <bar> :!clear; g++ % && ./a.out<enter>

"vim-go
".go 파일에서 c-] , c-t 등 godef 관련 shortcut 이 아래 단축키 설정과 충돌해 비활성화
let g:go_auto_sameids = 0
let g:go_def_mapping_enabled=0
let g:go_fmt_autosave = 1
let g:go_fmt_command = "gopls"
let g:go_highlight_build_constraints = 1
let g:go_highlight_fields = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
":GoMetaLinter 명령실행시 동작할 커맨드
let g:go_metalinter_command = "golangci-lint"
"최신 golangci-lint 에서 --deadline 옵션이 --timeout 으로 변경됨
"https://github.com/golangci/golangci-lint/pull/793/files
"vim-go 에서는 아직 deadline 을 사용하고 있어 주석처리함
"let g:go_metalinter_deadline = "5s"
"golangci-lint 에서 활성화할 항목
"vet -> govet 으로 바뀜
let g:go_metalinter_enabled = ['govet', 'revive', 'errcheck']
let g:go_version_warning = 0
autocmd filetype go nnoremap <f2> :GoRename<enter>
autocmd filetype go nnoremap <f5> :w <bar> :!clear; <enter> :GoRun<enter>
autocmd filetype go nnoremap <f7> :w <bar> :!clear; <enter> :GoBuild<enter>
autocmd filetype go nnoremap <f12> :GoDef<enter>
autocmd filetype go nnoremap <leader>d :GoDef<enter>
autocmd filetype go nnoremap <leader>r :GoReferrers<enter>
autocmd filetype go nnoremap <leader>i :w <bar> :GoImports<enter>
autocmd filetype go nnoremap <leader>g :GoGuruScope .<enter>
autocmd filetype go nnoremap <leader>v :GoVet<enter>:GoLint<enter>
"go.mod 의 go 버전업 수정 후 gopls 자동import안됨 :GoDef 실행시 no packages 등의 문제가 생기면
"다음으로 바이너리를 업데이트해야 한다.
autocmd filetype go nnoremap <leader>ub :GoUpdateBinaries<enter>
autocmd filetype go nnoremap <leader>ib :GoInstallBinaries<enter>

"black
autocmd filetype python nnoremap <leader>b :Black<enter>
autocmd filetype python nnoremap <leader>v :BlackVersion<enter>

"jedi-vim (python autocomplete)
"neovim 에서 jedi-vim 사용을 위해 pynvim 설치 필요
"pip install pynvim
let g:jedi#goto_command = "<leader>d" "This function first tries jedi#goto_definitions, and falls back to jedi#goto_assignments
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_stubs_command = "<leader>s"
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
"let g:jedi#usages_command = "<leader>n"
let g:jedi#usages_command = "<leader>r"
let g:jedi#completions_command = "<C-Space>"
"let g:jedi#rename_command = "<leader>r"
let g:jedi#rename_command = "<f2>"
let g:jedi#environment_path = "/usr/bin/python3"
let g:jedi#completions_enabled = 1
let g:jedi#popup_on_dot = 1
let g:jedi#popup_select_first = 0

"rust.vim
autocmd filetype rust nnoremap <leader>f :RustFmt<enter>
let g:rustfmt_autosave=1
