#!/bin/sh

nvram -d boot-args

TMPMOUNT=`/usr/bin/mktemp -d /tmp/vmware-tools.XXXX`
hdiutil attach /private/tmp/darwin.iso -mountpoint "$TMPMOUNT"

echo "Installing VMware tools.."
installer -pkg "$TMPMOUNT/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /

# This usually fails
hdiutil detach "$TMPMOUNT"
rm -rf "$TMPMOUNT"
rm -f "$TOOLS_PATH"

# Point Linux shared folder root to that used by OS X guests,
# useful for the Hashicorp vmware_fusion Vagrant provider plugin
mkdir /mnt
ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs

# Reboot
shutdown -r now
sleep 60
