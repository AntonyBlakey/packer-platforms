#!/bin/bash

set -e

export DIR=$1

if [[ ! -f "$DIR/vars.json" ]] ; then
    echo "Cannot find $DIR/vars.json"
    exit 1
fi

function cleanUp() {
    rm -f "osx/setup-miscellaneous-ui.sh"
}

trap cleanUp EXIT INT TERM

sed -f ../packer-config.sed < "osx/template-setup-miscellaneous-ui.sh" > "osx/setup-miscellaneous-ui.sh"
packer build -var rootdir=$(cd .. ; pwd) -var-file=vars.json -var-file="$DIR/vars.json" osx/packer.json

trap - EXIT INT TERM
cleanUp
exit 0
