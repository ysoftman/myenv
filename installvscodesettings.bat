@rem 참고 EOL(End Of Line) 가 CRLF 로 설정되어 있어야 한다.
@rem 윈도우 vscode 환경 구성
@rem 설정 파일 적용
copy /v /y .\vscode_settings\*.json %APPDATA%\Code\User

@rem installvscodeextension.sh 의 extension 들을 cmd /c 붙여서 실행
@rem /f 옵션(쉽표 또는 공백으로 구분되는 모든 토큰을)
for /f "tokens=* delims= " %%i in ('findstr "code" installvscodeextension.sh') do cmd /c %%i
