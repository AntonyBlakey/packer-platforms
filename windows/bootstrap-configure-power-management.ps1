# Disable hibernation
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -Name HibernateFileSizePercent -Value 0 -Type DWord
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power -Name HibernateEnabled -Value 0 -Type DWord

# Set power configuration to High Performance
powercfg.exe -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Turn off monitor timeout
powercfg.exe -Change -monitor-timeout-ac 0
powercfg.exe -Change -monitor-timeout-dc 0
