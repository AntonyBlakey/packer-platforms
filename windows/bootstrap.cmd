cmd /c a:\bootstrap-disable-uac.cmd

set bitsadmin=
for %%i in (bitsadmin.exe) do set bitsadmin=%%~$PATH:i
if not defined bitsadmin set bitsadmin=%SystemRoot%\System32\bitsadmin.exe

set HTTP_SERVER=http://192.168.0.23:9000

cmd /c a:\bootstrap-upload.cmd

cmd /c a:\bootstrap-install-powershell2.cmd
cmd /c a:\bootstrap-install-dotnet452.cmd
cmd /c a:\bootstrap-install-powershell3.cmd
cmd /c a:\bootstrap-set-powershell-execution-policy.cmd

C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-configure-passwords.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-configure-power-management.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-configure-servermanager.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-miscellaneous-ui-preferences.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-set-all-network-interfaces-to-private.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-install-openssh.ps1
C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File a:\bootstrap-configure-winrm.ps1
