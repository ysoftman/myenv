# myenv
개인 환경 백업 및 복구 자동화 스크립트~ :smile:

Mac, CentOS, Ubuntu 환경에서 사용 

# 사용방법
- 전체 백업시
```bash
sh ./backup_my_setting.sh
```

- 전체 설치
```bash
sh ./installall.sh
```

- 기본 설치 환경 구성(zsh, python, ruby ...), 아래 개별 설치시 선행되어야 함
```bash
sh ./installcommon.sh
```

- zsh 기반 prezto 설치
```bash
zsh ./installprezto.zsh
```

- zsh 기반 oh-my-zsh 설치
```bash
zsh ./installohmyzsh.zsh
```

- 기본 설정 설치(git config, bashrc, zshrc, vimrc ...)
```bash
sh ./installconfig.sh
```

- vim 플러그인 설치
```bash
sh ./installvimplugin.sh
```

- pip 로 프로그램 설치
```bash
sh ./installbypip.sh
```

- brew 로 프로그램 설치(Mac)
```bash
sh ./installbybrew.sh
```

- mac app 설치(Mac)
```bash
sh ./install_mac_app.sh
```

# 참고
- Ubuntu 환경에서 sh -> dash 쉘로 링크되어 있어 bash 로 쉘스크립트를 실행하던가 아래와 같이 sh -> bash 링크 해준다.
```bash
sudo unlink /bin/sh
sudo ln -s /bin/bash /bin/sh
```
