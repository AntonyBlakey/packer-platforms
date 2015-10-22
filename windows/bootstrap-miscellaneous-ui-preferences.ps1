Set-Location -Path "HKCU:\Control Panel\International"

# 24 hour clock
Set-ItemProperty -Path . -Name sShortTime -Value "HH:mm"
Set-ItemProperty -Path . -Name sTimeFormat -Value "HH:mm:ss"

Set-Location -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Default is 1 - hide file extensions
Set-ItemProperty -Path . -Name HideFileExt -Value 0 -Type DWord

# Default is 2 - do not show hidden files and folders
Set-ItemProperty -Path . -Name Hidden -Value 1 -Type DWord

# Default FullPath 0
Set-ItemProperty -Path . -Name FullPath -Value 1 -Type DWord

# Default FullPathAddress 0
Set-ItemProperty -Path . -Name FullPathAddress -Value 1 -Type DWord
