"neovim(nvim) 에서 .vimrc 설정 가져오기
set runtimepath+=~/.vim,~/.vim/after
set packpath+=~/.vim
source ~/.vimrc

call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'davidhalter/jedi-vim'
Plug 'dense-analysis/ale' "syntasitc alternative
Plug 'fatih/vim-go'
Plug 'glench/vim-jinja2-syntax'
Plug 'groenewege/vim-less'
Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
Plug 'johngrib/vim-game-code-break'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/space-vim-dark'
Plug 'majutsushi/tagbar'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'pangloss/vim-javascript'
Plug 'powerline/fonts'
Plug 'preservim/nerdcommenter'
Plug 'psf/black'
Plug 'rust-lang/rust.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'valloric/youcompleteme'
call plug#end()

