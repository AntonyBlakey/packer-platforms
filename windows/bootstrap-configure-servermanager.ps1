# Doesn't hurt to do this on every OS.

# http://www.windowsnetworking.com/kbase/WindowsTips/WindowsServer2008/AdminTips/Admin/AQuickTipToDisableInitialConfigurationTasksList.html
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\Oobe -Name DoNotOpenInitialConfigurationTasksAtLogon -Value 1 -Type DWord -Force

# http://www.petenetlive.com/KB/Article/0000042.htm
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -Value 1 -Type DWord -Force
