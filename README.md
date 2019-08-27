# myenv

개인 환경 백업 및 복구 자동화 스크립트~ :smile:

Mac, CentOS, Ubuntu 환경에서 사용

## 사용방법

myenv 는 ~/workspace/myenv 에 위치해야 한다.

```bash
# 전체 백업
sh ./backupmysetting.sh

#전체 설치(아래 모든 설치 스크립트 포함)
sh ./installall.sh

# 기본 설치 환경 구성(zsh, python, ruby ...), 아래 개별 설치시 선행되어야 함
sh ./installcommon.sh

# powerline 폰트 설치
sh ./installpowerlinefont.sh

# zsh 기반 black-void-zsh 설치
zsh ./installblackvoidzsh.zsh

# zsh 기반 prezto 설치
zsh ./installprezto.zsh

# zsh 기반 oh-my-zsh 설치
zsh ./installohmyzsh.zsh

# 기본 설정 설치(git config, bashrc, zshrc, vimrc ...)
sh ./installconfig.sh

# vim 설치
sh ./installvim.sh

# pip 로 프로그램 설치
sh ./installpip.sh

# brew 로 프로그램 설치(Mac)
sh ./installbrew.sh

# mac app 설치(Mac)
sh ./installapp.sh

# vscode settings 적용(Mac), Windows 는 installvscodesettings.bat 사용
sh ./installvscodesettings.sh
```

## 참고

- Ubuntu 환경에서 sh -> dash 쉘로 링크되어 있어 bash 로 쉘스크립트를 실행하던가 아래와 같이 sh -> bash 링크 해준다.

```bash
sudo unlink /bin/sh
sudo ln -s /bin/bash /bin/sh
```

- iterm2 설정

```text
color presets : git clone https://github.com/bahlo/iterm-colors 후 darkside, one dark, ... 등 선택
font : 16, font-hack-nerd-font (installbrew.sh 에서 설치)
```
