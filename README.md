# myenv

개인 환경 백업 및 복구 자동화 스크립트~ :smile:

- myenv 는 ~/workspace/myenv 에 위치해야 한다.
- 설치 & 백업

```bash
# 설정 및 프로그램 목록등 백업
bash ./backupmysetting.sh

# 전체 설치
bash ./installall.sh

# 필요한 환경/프로그램은 installxxx.sh 사용
```

- mac iterm2 사용시

  - iterm2 > general > selection > application in terminal may access clipboard 활성화(tmux 환경에서 클립보드를 사용하기 위해)
  - iterm2 > profiles > colors > color presets 선택
  - iterm2 > profiles > text > font : 18, font-hack-nerd-font(installbrew.sh 에서 설치함)
  - iterm2 에서 tmux 사용시 더블 클릭은 alt + double click(triple click) 로 사용해야 한다.

- windows alacritty 사용시

  - 설정 파일은 다른 OS 도 같이 사용하니 윈도우 전용으로 수정하지 않는다. 대신 기본 powershell 에서 wsl 실행하면 된다.

- windows terminal 사용시

  - hack nerd 폰트 다운로드 받아 설치 <https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip>
  - terminal 에서 ctrl + , 로 설정 파일을 오픈 후 windows_terminal/settings.json 내용 복사 & 붙여넣기로 설정 적용
  - 터미널앱 사용(창 선택)시 배경색이 바뀌는 경우, 윈도우 투명도(settings > transparency effects > off)를 비활성화 해야 한다.

- Ubuntu, sh > dash 쉘로 링크되어 있어 bash 로 쉘스크립트를 실행하던가 아래와 같이 sh > bash 링크 해준다.

```bash
sudo unlink /bin/sh
sudo ln -s /bin/bash /bin/sh
```
