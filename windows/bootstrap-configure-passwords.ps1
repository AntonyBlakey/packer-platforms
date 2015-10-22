# Password for 'vagrant' user never expires
Get-WmiObject -Class Win32_UserAccount -Filter "name='vagrant'" | Set-WmiInstance -Argument @{PasswordExpires = 0}

# Passwords never get changed
# http://support.microsoft.com/kb/154501
Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters -Name DisablePasswordChange -Value 2 -Type DWord -Force
