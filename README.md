# myenv

개인 환경 백업 및 복구 자동화 스크립트~ :smile:

Mac, CentOS, Ubuntu 환경에서 사용

## 사용방법

```bash
# 전체 백업
sh ./backup_my_setting.sh

#전체 설치(아래 모든 설치 스크립트 포함)
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

# pip 로 프로그램 설치
sh ./installbypip.sh

# brew 로 프로그램 설치(Mac)
sh ./installbybrew.sh

# mac app 설치(Mac)
sh ./install_mac_app.sh

# vscode settings 적용(Mac), Windows 는 install_win_vscode_settings.bat 사용
sh ./install_mac_vscode_settings.sh
```

## 참고

- Ubuntu 환경에서 sh -> dash 쉘로 링크되어 있어 bash 로 쉘스크립트를 실행하던가 아래와 같이 sh -> bash 링크 해준다.

```bash
sudo unlink /bin/sh
sudo ln -s /bin/bash /bin/sh
```

- iterm2 설정

```text
color presets : darkside --> git clone https://github.com/bahlo/iterm-colors
font : 14pt monaco
```
