set CMD="Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
set POWERSHELL=WindowsPowerShell\v1.0\powershell.exe

C:\WINDOWS\system32\%POWERSHELL% -Command %CMD%
if exist C:\Windows\SysWOW64\cmd.exe C:\Windows\SysWOW64\cmd.exe /c C:\WINDOWS\SysWOW64\%POWERSHELL% -Command %CMD%
