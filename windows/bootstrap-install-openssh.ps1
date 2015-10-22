$vagrant_dir = "C:\Users\vagrant"
$openssh_dir = "C:\Program Files\OpenSSH"

########################################################################################

# Beware that the installation will fail on Server 2008 / 2008r2 if the password is too weak!
Start-Process -Wait "C:\Windows\Temp\setupssh.exe" "/S /privsep=1 /password=D@rj33l1ng /serveronly=1"
Stop-Service OpenSSHD -Force

########################################################################################

$sshd_config = Get-Content "$openssh_dir\etc\sshd_config"
$sshd_config = $sshd_config -replace 'StrictModes yes', 'StrictModes no'
$sshd_config = $sshd_config -replace 'UsePrivilegeSeparation sandbox', 'UsePrivilegeSeparation no'
$sshd_config = $sshd_config -replace '#PubkeyAuthentication yes', 'PubkeyAuthentication yes'
$sshd_config = $sshd_config -replace '#PermitUserEnvironment no', 'PermitUserEnvironment yes'
$sshd_config = $sshd_config -replace 'Banner /etc/banner.txt', '#Banner /etc/banner.txt'
$sshd_config = $sshd_config -replace '#UseDNS yes', 'UseDNS no'
$sshd_config = $sshd_config -replace '#AuthorizedKeysFile	.ssh/authorized_keys', 'AuthorizedKeysFile /home/vagrant/.ssh/authorized_keys'
Set-Content "$openssh_dir\etc\sshd_config" $sshd_config

# re-enable a cipher (arcfour) that the vagrant client uses
Add-Content "$openssh_dir\etc\sshd_config" "Ciphers arcfour,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com"

########################################################################################

# use c:\Windows\Temp as /tmp location
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$openssh_dir\tmp"
& "C:\Program Files\OpenSSH\bin\junction.exe" /accepteula "$openssh_dir\tmp" "C:\Windows\Temp"

########################################################################################

New-Item -ItemType Directory -Force -Path "$vagrant_dir\.ssh"
Add-Content "$vagrant_dir\.ssh\environment" "TEMP=C:\Windows\Temp"
$is_64bit = [IntPtr]::size -eq 8
if ($is_64bit) {
    Add-Content "$vagrant_dir\.ssh\environment" "ProgramFiles(x86)=C:\Program Files (x86)"
    Add-Content "$vagrant_dir\.ssh\environment" "ProgramW6432=C:\Program Files"
    Add-Content "$vagrant_dir\.ssh\environment" "CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files"
    Add-Content "$vagrant_dir\.ssh\environment" "CommonProgramW6432=C:\Program Files\Common Files"
}

cp "C:\Windows\Temp\vagrant.pub" "$vagrant_dir\.ssh\authorized_keys"
icacls.exe "$vagrant_dir\.ssh" /grant "vagrant:(OI)(CI)F"

########################################################################################

# configure firewall
netsh advfirewall firewall add rule name="SSHD" dir=in action=allow service=OpenSSHd enable=yes
netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="$openssh_dir\usr\sbin\sshd.exe" enable=yes
netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

########################################################################################

# We need the ssh login to be able to start up desktop apps, so it has to run not as a service
# but as a user app under the vagrant user.

sc.exe delete OpenSSHd

icacls.exe "$openssh_dir\etc" /grant "vagrant:F" /T
icacls.exe "$openssh_dir\etc" /inheritance:r /T

Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name OpenSSH -Value "$openssh_dir\usr\sbin\sshd.exe"
