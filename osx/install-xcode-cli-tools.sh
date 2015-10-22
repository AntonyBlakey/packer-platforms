#!/bin/sh

TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
hdiutil attach /private/tmp/clitools.dmg -mountpoint "$TMPMOUNT"
find $TMPMOUNT \( -name '*.mpkg' -or -name '*.pkg' \) -exec installer -pkg "{}" -target / \;
hdiutil detach "$TMPMOUNT"
rm -rf "$TMPMOUNT"
