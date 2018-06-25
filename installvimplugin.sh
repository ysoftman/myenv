#!/bin/bash
# ysoftman
# vim plugin 설정 스크립트
# sh installvimplugin.sh
# export 를 현재 쉘에 반영하고 싶다면 source installvimplugin.sh

# go, ruby, mercurial, python, cmake, ctags 설치 및 환경변수 설정
if [ $(uname) == 'Darwin' ]; then
	echo 'OSX Environment'
	brew install go
	export GOROOT=/usr/local/bin/go
	brew install ruby lua mercurial python cmake ctags python3 tig
elif [ $(uname) == 'Linux' ]; then
	echo 'Linux Environment'
	# yum 실행보기
	yum --version
	# yum 실행후 exit code 0(SUCCESS) 이라면 사용할수 있다.
	if [ $? == 0 ]; then
		package_program="yum -y"
	else
		package_program="apt-get"
	fi
	sudo ${package_program} install gcc-c++ wget go vim
	export GOROOT=/usr/bin/go
	sudo ${package_program} install ruby lua mercurial python-dev cmake ctags python34-devel tig
else
	echo 'Only OS-X or Linux... exit'
	# 소스 빌드 및 설치
	#wget https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz
	#tar -zxvf go1.4.linux-amd64.tar.gz
	#echo 'build and install golang'
	#export GOROOT=$PATH:$HOME/gGo
	exit
fi

installvim() {
	# 최신 버전 vim 설치
	if [ ! -d 'vim-8.0.1432' ]; then
		# git clone https://github.com/vim/vim.git
		wget "https://github.com/vim/vim/archive/v8.0.1432.tar.gz"
		tar zxvf v8.0.1432.tar.gz
	fi
	cd vim-8.0.1432/src
	make distclean
	# youcompleteme 플러그인이 python 을 사용하기때문에  python2,3 을 지원하는 vim 으로 빌드되어야 한다.
	# ruby, lua 지원도 포함해두자
	./configure --enable-pythoninterp=yes --enable-python3interp=yes --enable-rubyinterp=yes --enable-luainterp=yes
	make -j 8
	sudo make install
}

cur_vim_version=$(vim --version | grep 'Vi IMproved' | awk '{print $5}')
echo "cur_vim_version : ${cur_vim_version}"
if [ ${cur_vim_version} != "8.0" ]; then
	echo "cur_vim_version < 8.0"
	echo "installvim()..."
	installvim
fi


GOPATH=${HOME}/workspace/gopath
echo GOPATH=${GOPATH}

# GOPATH 디렉토리가 없다면 생성
mkdir -p ${GOPATH}

export GOPATH=${GOPATH}
export PATH=$PATH:$GOROOT:$GOPATH

# 다음 디렉토리가 없다면 생성
mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/bundle

# vimrc 백업하기
TEMP_FILE="ysoftman_vimrc_backup.temp"
# ysoftman_settings start ~ end 부분은 제외 하고 백업
# cat ~/.vimrc | sed "/^\" ysoftman_settings_start/,/^\" ysoftman_settings_end/d;" > ${TEMP_FILE}
cat ~/.vimrc | sed "/ysoftman_settings_start/,/ysoftman_settings_end/d;" > ${TEMP_FILE}
# vimrc 다시 작성
cat ${TEMP_FILE} > ~/.vimrc
# TEMP_FILE 삭제
rm -f ${TEMP_FILE}


echo '"""""""""" ysoftman_settings_start' >>  ~/.vimrc

########################
# vim 패키지(플러그인) 관지자 - pathogen 설치
# vim-pathogen 을 ~/.vim/autoload 에 다운 받는다
#cd ~/.vim/autoload
#git clone https://github.com/tpope/vim-pathogen.git
#cp -v ./vim-pathogen/autoload/pathogen.vim ./
#echo '
#" pathogen 설정
#" 참고 https://github.com/tpope/vim-pathogen.git
#execute pathogen#infect()
#filetype plugin indent on
#' >> ~/.vimrc

# YouCompleteMe
# python-dev, cmake 설치되어있어야함
# YCM 을 ~/.vim/bundle 에 다운 받는다
# cd ~/.vim/bundle
# git clone https://github.com/Valloric/YouCompleteMe.git
# cd YouCompleteMe
# git submodule update --init --recursive
# sh ./install.sh

# Tagbar
# vim 에서 :TagbarToggle 을 사용하면 오른쪽에 태그 창이 보인다.
# ctags 설치되어 있어야함
# Tagbar 을 ~/.vim/bundle 에 다운 받는다
# cd ~/.vim/bundle
# git clone https://github.com/majutsushi/tagbar.git

# NertdTree
# vim 에서 :NERDTreeToggle 을 사용하면 오른쪽에 태그 창이 보인다.
# cd ~/.vim/bundle
# git clone https://github.com/scrooloose/nerdtree.git

# powerline font(airline 꺽쇄 표시를 잘 표현하기 위해)
# cd ~/.vim/bundle
# git clone https://github.com/powerline/fonts

# airline
# cd ~/.vim/bundle
# git clone https://github.com/bling/vim-airline
# git clone https://github.com/vim-airline/vim-airline

# syntastic
# cd ~/.vim/bundle
# git clone https://github.com/scrooloose/syntastic

# vim-colors-solarized
# cd ~/.vim/bundle
# git clone https://github.com/altercation/vim-colors-solarized

# ondeark
# cd ~/.vim/bundle
# git clone https://github.com/joshdick/onedark.vim

# ctrlp
# ctrl + p 로 파일명 검색
# cd ~/.vim/bundle
# git clone https://github.com/kien/ctrlp.vim

# fzf
# gem install curses
# rm -rfv ~/.fzf
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

# vim-go
#:GoRun (go 실행)
#:GoBuild (go 빌드)
#:GoDoc (go 문서)
#:GoDef (go 변수 정의)
#:GoFmt(go 형식 맞춤)
#:GoImports (go 패키지 자동 임포트)
# cd ~/.vim/bundle
# git clone https://github.com/fatih/vim-go.git

# vim-indent-guides
# cd ~/.vim/bundle
# git clone https://github.com/nathanaelkane/vim-indent-guides


########################
# vim 패키지(플러그인) 관지자 - vundle 설치
# ruby 가 설치되어 있어야함
# vundle 을 ~/.vim/bundle 에 다운 받는다
# cd ~/.vim/bundle
# git clone https://github.com/VundleVim/Vundle.vim.git
# echo '
# " Vundle 설정
# " 참고 https://github.com/VundleVim/Vundle.vim
# set nocompatible              " be iMproved, required
# filetype off                  " required
# set rtp+=~/.vim/bundle/Vundle.vim
# ' >> ~/.vimrc
# # vundle plugin 설정
# echo 'call vundle#begin()
# ' >> ~/.vimrc
# echo "Plugin 'VundleVim/Vundle.vim'
# Plugin 'valloric/youcompleteme'
# Plugin 'majutsushi/tagbar'
# Plugin 'scrooloose/nerdtree'
# Plugin 'fatih/vim-go'
# Plugin 'powerline/fonts'
# Plugin 'vim-airline/vim-airline'
# Plugin 'vim-airline/vim-airline-themes'
# Plugin 'scrooloose/syntastic'
# Plugin 'altercation/vim-colors-solarized'
# Plugin 'joshdick/onedark.vim'
# Plugin 'kien/ctrlp.vim'
# Plugin 'junegunn/fzf'
# Plugin 'nathanaelkane/vim-indent-guides'
# " >> ~/.vimrc
# echo 'call vundle#end()            " required
# filetype plugin indent on    " required
# ' >> ~/.vimrc

#######################
# vim-plug 설치(플러그인 매니저중 플러그인 설치 속도가 가장 빠름)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "call plug#begin('~/.vim/plugged')
Plug 'valloric/youcompleteme'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go'
\"Plug 'powerline/fonts'
\"Plug 'vim-airline/vim-airline'
\"Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/syntastic'
Plug 'altercation/vim-colors-solarized'
Plug 'joshdick/onedark.vim'
Plug 'kien/ctrlp.vim'
Plug 'junegunn/fzf', { 'dir': '~/.vim/plugged/fzf', 'do': './install --all' }
Plug 'nathanaelkane/vim-indent-guides'
call plug#end()
" >> ~/.vimrc
# vim 실행 후 PlugInstall 로 Plugin 으로 설정한 플러그인 설치하고 모두 종료
# vim -c PlugInstall -c qall
vim +PlugInstall +qall
# vim 실행 후 GoInstallBinaries 로 go 바이너리설치, $GOPATH/bin 에 필요한 파일들이 설치하고 모두 종료
# 처음 GoInstallBinaries 설치시 파일이 없어 설치한다는 메시지가 넘어가기 위해 사용자 입력을 기다리게 되면
# dockerfile 로 이미지 빌드시(사용자 입력을 받을 수 없게 되어 있어) 문제가 되어 slient 모드로 설치한다.
vim +'silent :GoInstallBinaries' +qall

# "The ycmd server SHUT DOWN (restart with :YcmRestartServer)" 메시지가 발생하는 경우가 있어 설치 진행
cd ~/.vim/plugged/youcompleteme/
git submodule update --init --recursive
./install.py
cd -

#######################
# 사용자 설정
echo '
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
set listchars=tab:→\ ,space:·,trail:·,precedes:«,extends:»,eol:¶
let g:go_version_warning = 0
' >> ~/.vimrc

# vim-colors-solarized
# echo "syntax enable
# let g:solarized_termtrans = 1
# let g:solarized_termcolors=256
# let g:solarized_contrast=\"high\"
# let g:solarized_visibility=\"high\"
# set background=dark
# colorscheme solarized
# " >> ~/.vimrc

# onedark
echo 'syntax on
let g:onedark_termcolors=256
colorscheme onedark
' >> ~/.vimrc

# airline 대신 lightline 사용
# airline
# echo "set laststatus=2
# let g:airline#extensions#tabline#enabled = 1
# let g:airline#extensions#tabline#left_sep = ' '
# let g:airline#extensions#tabline#left_alt_sep = '|'
# \" iterm -> non-ascii font 를 powerline 폰트로 변경 후 사용
# let g:airline_powerline_fonts = 1
#" >> ~/.vimrc

# lightline 화살표 폰트가 없어 powerline 폰트가 필요 없다
echo "set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'one',
      \ }
" >> ~/.vimrc

# vim-indent-guides
echo 'let g:indent_guides_auto_colors = 0
hi IndentGuidesOdd  ctermbg=black
hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_enable_on_vim_startup = 1
' >> ~/.vimrc

# fzf
# ~/.fzf/install --all
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# echo "set rtp+=~/.fzf
# " >> ~/.vimrc

# 단축키 설정
echo '" 단축키 설정
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
' >> ~/.vimrc

# 참고, 뉴라인으로 끝나면 이 스크립트가 실행될때마다 뉴라인이 추가된다.
echo '"""""""""" ysoftman_settings_end' >>  ~/.vimrc

