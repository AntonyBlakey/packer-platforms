#/bin/bash -eux

echo "Enabling automatic GUI login for the vagrant user"

/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser vagrant
cp -f /private/tmp/kcpassword /etc/
