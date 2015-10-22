Remove-Item C:\Windows\Temp\* -Recurse -Force

# see http://www.winhelponline.com/blog/fix-corrupted-recycle-bin-windows-7-vista/
Remove-Item 'C:\$Recycle.bin' -Recurse -Force
