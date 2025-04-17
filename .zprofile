# login shell 시작시 로딩할 설정들

if [ -f  $HOME/.zprezto/runcoms/zprofile ]; then
    .  $HOME/.zprezto/runcoms/zprofile
fi

# interactive(prompt) 쉘 시작시 자동 로딩되어 여기선 로딩하지 않는다.
# if [ -f ~/.zshrc ]; then
#     . ~/.zshrc 
# fi

