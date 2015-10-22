"%bitsadmin%" /Transfer "Vagrant Public Key" /download /priority FOREGROUND "%HTTP_SERVER%/packer/vagrant.pub" "C:\Windows\Temp\vagrant.pub"
"%bitsadmin%" /Transfer "OpenSSH" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/setupssh-6.7p1-2.exe" "C:\Windows\Temp\setupssh.exe"
"%bitsadmin%" /Transfer "7zip" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/7z920.exe" "C:\Windows\Temp\7zip.exe"

"%bitsadmin%" /Transfer ".Net 4.5.2" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/NDP452-KB2901907-x86-x64-AllOS-ENU.exe" "C:\Windows\Temp\dotnet452.exe"

IF "%PROCESSOR_ARCHITECTURE%" == "x86" (
   "%bitsadmin%" /Transfer "Powershell 2 for windows 2008 x86" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/KB968930-win2008-x86.msu" "C:\Windows\Temp\KB968930-win2008.msu"
   "%bitsadmin%" /Transfer "Powershell 3 for windows 6.0 x86" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/Windows6.0-KB2506146-x86.msu" "C:\Windows\Temp\Windows6.0-KB2506146.msu"
   "%bitsadmin%" /Transfer "Powershell 3 for windows 6.1 x86" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/Windows6.1-KB2506143-x86.msu" "C:\Windows\Temp\Windows6.1-KB2506143.msu"
) ELSE (
   "%bitsadmin%" /Transfer "Powershell 2 for windows 2008 x64" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/KB968930-win2008-x64.msu" "C:\Windows\Temp\KB968930-win2008.msu"
   "%bitsadmin%" /Transfer "Powershell 3 for windows 6.0 x64" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/Windows6.0-KB2506146-x64.msu" "C:\Windows\Temp\Windows6.0-KB2506146.msu"
   "%bitsadmin%" /Transfer "Powershell 3 for windows 6.1 x64" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/Windows6.1-KB2506143-x64.msu" "C:\Windows\Temp\Windows6.1-KB2506143.msu"
)

"%bitsadmin%" /Transfer "VMWare Tools" /download /priority FOREGROUND "%HTTP_SERVER%/Windows/Utilities/vmware_tools.iso" "C:\Windows\Temp\vmware_tools.iso"
