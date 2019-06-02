cls
@REM add registry cmd autorun
reg add "HKCU\Software\Microsoft\Command Processor" /v autorun /t reg_multi_sz /d %cd%\alias.bat /f
reg query "HKCU\Software\Microsoft\Command Processor" /v autorun

@REM set alias(doskey)
doskey vi=vim
doskey work=cd /d d:\ysoftman\workspace
doskey testcode=cd /d d:\ysoftman\workspace\test_code
