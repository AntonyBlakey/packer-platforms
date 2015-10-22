#!/bin/bash

set -e

export DIR=$1

if [[ ! -f "$DIR/template-Autounattend.xml" ]] ; then
    echo "Cannot find $DIR/template-Autounattend.xml"
    exit 1
fi

function cleanUp() {
    rm -f "$DIR/Autounattend.xml"
    rm -f "../Windows/Utilities/vmware_tools.iso"
}

trap cleanUp EXIT INT TERM

cp "/Applications/VMware Fusion.app/Contents/Library/isoimages/windows.iso" "../Windows/Utilities/vmware_tools.iso"
sed -f ../packer-config.sed < "$DIR/template-Autounattend.xml" > "$DIR/Autounattend.xml"
packer build -var rootdir=$(cd .. ; pwd) -var-file=vars.json -var-file="$DIR/vars.json" windows/packer.json

trap - EXIT INT TERM
cleanUp
exit 0
