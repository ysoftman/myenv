@cls
@REM add registry cmd autorun
@rem reg add "HKCU\Software\Microsoft\Command Processor" /v autorun /t reg_multi_sz /d c:\ysoftman\workspace\myenv\alias.bat /f
@rem reg query "HKCU\Software\Microsoft\Command Processor" /v autorun

@rem wsl 환경에서 vscode 실행 에러로 alais.bat 자동실행 삭제
@rem delete registry cmd autorun
@rem reg delete "HKCU\Software\Microsoft\Command Processor"

@REM set alias(doskey)
doskey vi=vim
doskey work=cd /d c:\ysoftman\workspace
doskey testcode=cd /d c:\ysoftman\workspace\test_code
