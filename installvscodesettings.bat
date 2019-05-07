@cls
@rem 참고 EOL(End Of Line) 가 CRLF 로 설정되어 있어야 한다.
@rem 윈도우 vscode 환경 구성
@rem 설정 파일 적용
copy /v /y .\vscode_settings\*.json %APPDATA%\Code\User

@rem installvscodeextension.sh 의 extension 들을 cmd /c 붙여서 실행
@rem /f 옵션(쉽표 또는 공백으로 구분되는 모든 토큰을)
@REM (명령) 수행시 cmd /c 가 새로실행되어 autorun 되는 명령들 발생한다.
@REM 따라서 findstr 명령 결과를 임시파일로 저장해서 루프를 수행한다.
@findstr "code" installvscodeextension.sh > vscodeextension.tmp
@for /f "tokens=* delims= " %%i in (vscodeextension.tmp) do %%i
@del vscodeextension.tmp
