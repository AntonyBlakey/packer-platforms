:: see http://www.howtogeek.com/howto/windows-vista/enable-or-disable-uac-from-the-windows-vista-command-line/
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /d 0 /t REG_DWORD /f

:: Change remote UAC account policy
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /d 1 /t REG_DWORD /f
