#!/bin/bash

# ysoftman 저장소를 사용하는 소스들의 로컬 git 설정
find .. -name .git -type d > gitdirs
for item in `cat gitdirs`
do
    out=`(git -C ${item} remote -v | grep "https://github.com/ysoftman/" | wc -l | awk '{print$1}')`
    if [[ $out == 2 ]]; then
        # echo $item
        cat << zzz
git -C ${item} config user.email "ysoftman@gmail.com"
git -C ${item} config user.name "ysoftman"
zzz
        git -C ${item} config user.email "ysoftman@gmail.com"
        git -C ${item} config user.name "ysoftman"
    fi
done
rm -f gitdirs