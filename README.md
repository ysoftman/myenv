# myenv

개인 환경 백업 및 복구 자동화 스크립트~ :smile:

## common

myenv 는 ~/workspace/myenv 에 위치해야 한다.

```bash
# 전체(설정 및 프로그램 목록등) 백업
sh ./backupmysetting.sh

# 전체 설치(아래 모든 설치 스크립트 포함)
sh ./installall.sh

# 기본 설치 환경 구성(zsh, python, ruby ...), 아래 개별 설치시 선행되어야 함
sh ./installcommon.sh

# powerline 폰트 설치
sh ./installpowerlinefont.sh

# zsh 기반 prezto 설치
zsh ./installprezto.zsh

# zsh 기반 oh-my-zsh 설치
zsh ./installohmyzsh.zsh

# 기본 설정 설치(git config, bashrc, zshrc, vimrc ...)
sh ./installconfig.sh

# vim 설치
sh ./installvim.sh

# tmux 플러그인 매니저 설치
sh ./installtmuxplugin.sh

# pip 로 프로그램 설치
sh ./installpip.sh

# cargo 로 프로그램 설치
sh ./installcargo.sh
```

## Mac

```bash
# brew 로 프로그램 설치
sh ./installbrew.sh

# chrome, firefox, vscode, iterm 등의 app 설치
sh ./installapp.sh

# iterm-color 설치
sh ./installitermcolor.sh

# vscode settings 적용
sh ./installvscodesettings.sh
```

- iterm2 사용시
  - iterm2 > general > selection > application in terminal may access clipboard 활성화(tmux 환경에서 클립보드를 사용하기 위해)
  - iterm2 > profiles > colors > color presets > import item-color 경로(installitermcolor.sh 에서 설치함)에서 darkside, one dark 등 선택
  - iterm2 > profiles > text > font : 18, font-hack-nerd-font(installbrew.sh 에서 설치함)
  - iterm2 에서 tmux 사용시 더블 클릭은 alt + double click(triple click) 로 사용해야 한다.

### Windows

```bash
# doskey 로 alias 처럼 별칭 설정
alias.bat

# alacritty settings 적용
installalacrittysettings.bat

# hyper settings 적용
installhypersettings.bat

# vscode settings 적용
installvscodesettings.bat
# wsl 사용시
sh ./installvscodesettings.sh
```

- alacritty 사용시
  - 설정 파일은 다른 OS 도 같이 사용하니 윈도우 전용으로 수정하지 않는다. 대신 기본 powershell 에서 wsl 실행하면 된다.
- windows terminal 사용시
  - hack nerd 폰트 다운로드 받아 설치 <https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip>
  - terminal 에서 ctrl + , 로 설정 파일을 오픈 후 windows_terminal/settings.json 내용 복사 & 붙여넣기로 설정 적용
  - 터미널앱 사용(창 선택)시 배경색이 바뀌는 경우, 윈도우 투명도(settings > transparency effects > off)를 비활성화 해야 한다.

### Ubuntu

- sh > dash 쉘로 링크되어 있어 bash 로 쉘스크립트를 실행하던가 아래와 같이 sh > bash 링크 해준다.

  ```bash
  sudo unlink /bin/sh
  sudo ln -s /bin/bash /bin/sh
  ```
