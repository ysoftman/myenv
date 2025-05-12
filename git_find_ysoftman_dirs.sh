# 로컬에서 ysoftman 저장소들 사용하는 경로 모두 가져오기
git_find_ysoftman_dirs() {
    # IFS(Internal Field Separator) 를 space(디폴트)면
    # fd 결과 파일들이 한줄로 한번에 처리되는데 이때 File name too long 에러가 발생한다.
    # IFS 를 newline 로해 파일 1개씩 처리되도록 해야 한다.
    IFS=$'\n'
    # --no-ignore 옵션이 없으면 ~/workspace/ysoftman.github.io > .gitignore > .git 이 설정되어 있어 디렉토리가 제외된다.
    gitdirs=$(fd '\.git$' --hidden --no-ignore --type d $HOME/workspace)
    for item in ${gitdirs}; do
        out=$(git -C ${item} remote -v | rg -i -c "https://github.com/ysoftman/.*fetch" | awk '{print$1}')
        if [[ $out == 1 ]]; then
            echo "$item" | sed 's#.git/$##'
        fi
    done
    IFS=' '
}
git_find_ysoftman_dirs
