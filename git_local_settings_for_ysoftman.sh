#!/bin/bash
# ysoftman 저장소를 사용하는 소스들의 로컬 git 설정
if [ "$(which fd)" ]; then
    echo "using fd..."
    gitdirs=$(fd '\.git$' --hidden --type d ..)
else
    echo "using find..."
    gitdirs=$(find .. -name .git -type d)
fi

if [ "$(which rg)" ]; then
    echo "using rg(ripgrep)"
    grep="rg"
else
    echo "using grep"
    grep="grep"
fi

# for item in `cat gitdirs`
for item in ${gitdirs}; do
    out=$(git -C ${item} remote -v | grep -c "https://github.com/ysoftman/" | awk '{print$1}')
    if [[ $out == 2 ]]; then
        # echo $item
        cat <<zzz
git -C ${item} config user.email "ysoftman@gmail.com"
git -C ${item} config user.name "ysoftman"
zzz
        git -C ${item} config user.email "ysoftman@gmail.com"
        git -C ${item} config user.name "ysoftman"
    fi
done
