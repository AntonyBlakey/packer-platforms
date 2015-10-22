$is_64bit = [IntPtr]::size -eq 8

# Extract VMWare tools setup
Start-Process -Wait -FilePath "C:\Windows\Temp\7zip.exe" -ArgumentList "/S /D=C:\Windows\Temp\7zip"
C:\Windows\Temp\7zip\7z.exe -tiso x C:\Windows\Temp\vmware_tools.iso -oC:\Windows\Temp\vmware_tools > $null
Start-Process -Wait -FilePath "C:\Windows\Temp\7zip\Uninstall.exe" -ArgumentList "/S"

# Run VMWare tools setup
if ($is_64bit) { $exe_name = "setup64.exe" } else { $exe_name = "setup.exe" }
$p = Start-Process -Wait -PassThru -FilePath "C:\Windows\Temp\vmware_tools\$exe_name" -ArgumentList "/S /v ""/qn REBOOT=R ADDLOCAL=ALL"""

if ($p.ExitCode -eq 3010) {
    shutdown /r /t 5 /f /d p:4:1 /c "Reboot for VMWare Tools"
    Stop-Service winrm -Force
}

