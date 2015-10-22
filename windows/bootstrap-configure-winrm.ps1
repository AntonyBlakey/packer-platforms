Enable-PSRemoting -Force
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Otherwise the startup type is Automatic(Delayed) which is painful for vagrant
Set-Service WinRM -startuptype "Automatic"
