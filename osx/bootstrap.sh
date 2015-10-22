#!/bin/sh

date > /etc/box_build_time
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

# Set computer/hostname
COMPNAME=osx-10_${OSX_VERS}
scutil --set ComputerName ${COMPNAME}
scutil --set HostName ${COMPNAME}.vagrantup.com

# Install vagrant ssh key
mkdir /Users/vagrant/.ssh
chmod 700 /Users/vagrant/.ssh
cp /private/tmp/vagrant.pub /Users/vagrant/.ssh/authorized_keys
chmod 600 /Users/vagrant/.ssh/authorized_keys
chown -R vagrant /Users/vagrant/.ssh

# Create a group and assign the user to it
dseditgroup -o create vagrant
dseditgroup -o edit -a vagrant vagrant
