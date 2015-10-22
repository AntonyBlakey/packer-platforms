#!/bin/sh
#
# Preparation script for an OS X automated installation for use with Packer
#
# What the script does, in more detail:
#
# 1. Mounts the InstallESD.dmg using a shadow file, so the original DMG is left
#    unchanged.
# 2. Modifies the BaseSystem.dmg within in order to add an additional 'rc.cdrom.local'
#    file in /etc, which is a supported local configuration sourced in at boot time
#    by the installer environment. This file contains instructions to erase and format
#    'disk0', presumably the hard disk attached to the VM.
# 3. A 'veewee-config.pkg' installer package is built, which is added to the OS X
#    install by way of the OSInstall.collection file. This package creates the
#    'vagrant' user, configures sshd and sudoers, and disables setup assistants.
# 4. veewee-config.pkg and the various support utilities are copied, and the disk
#    image is saved to the output path.
#
# This script was written by Antony Blakey <antony.blakey@gmail.com>, derived largely from
# Tim Sutton's work at: https://github.com/timsutton/osx-vm-templates and information from
# http://forums.macrumors.com/threads/how-to-create-el-capitan-os-x-bootable-dvd.1923894/page-2#post-22048507
#
# Tim Sutton's original thanks:
#
# Idea and much of the implementation thanks to Pepijn Bruienne, who's also provided
# some process notes here: https://gist.github.com/4542016. The sample minstallconfig.xml,
# use of OSInstall.collection and readme documentation provided with Greg Neagle's
# createOSXInstallPkg tool also proved very helpful. (http://code.google.com/p/munki/wiki/InstallingOSX)
# User creation via package install method also credited to Greg, and made easy with Per
# Olofsson's CreateUserPkg (http://magervalp.github.io/CreateUserPkg)

set -e

HERE="$(cd $(dirname "$0"); pwd)"
SUPPORT_DIR="$HERE/support"

TEMP_DIR="$(/usr/bin/mktemp -d /tmp/prepare_iso.XXXX)"

MNT_ESD="$TEMP_DIR/esd"
mkdir "$MNT_ESD"

MNT_BASE_SYSTEM="$TEMP_DIR/basesystem"
mkdir "$MNT_BASE_SYSTEM"

function cleanup() {
    hdiutil detach -quiet -force "$MNT_ESD" || echo > /dev/null
    hdiutil detach -quiet -force "$MNT_BASE_SYSTEM" || echo > /dev/null
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT INT TERM

msg_status() {
    echo "\033[0;32m-- $1\033[0m"
}
msg_error() {
    echo "\033[0;31m-- $1\033[0m"
}


################################################################################################
# Validate arguments

usage() {
    cat <<EOF
Usage:
$(basename "$0") [-upi] "/path/to/Install OS X ???.app" /path/to/output/directory

Description:
Converts a 10.7+ installer image to a new image that contains components
used to perform an automated installation. The new image will be named
'OSX_InstallESD_[osversion].dmg.'

Optional switches:
  -u <user>
    Sets the username of the root user, defaults to 'vagrant'.

  -p <password>
    Sets the password of the root user, defaults to 'vagrant'.

  -i <path to image>
    Sets the path of the avatar image for the root user, defaulting to the vagrant icon.

EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Parse the optional command line switches
USER="vagrant"
PASSWORD="vagrant"
IMAGE_PATH="$SUPPORT_DIR/vagrant.jpg"

while getopts u:p:i: OPT; do
    case "$OPT" in
        u)
            USER="$OPTARG"
            ;;
        p)
            PASSWORD="$OPTARG"
            ;;
        i)
            IMAGE_PATH="$OPTARG"
            ;;
        \?)
            usage
            exit 1
            ;;
    esac
done

# Remove the switches we parsed above.
shift `expr $OPTIND - 1`

if [ $(id -u) -ne 0 ]; then
    msg_error "This script must be run as root, as it saves a disk image with ownerships enabled."
    exit 1
fi

ESD="$1"
if [ -e "$ESD/Contents/SharedSupport/InstallESD.dmg" ]; then
    ESD="$ESD/Contents/SharedSupport/InstallESD.dmg"
else
    msg_error "Can't locate an InstallESD.dmg in this source location $ESD!"
fi

OUT_DIR="$2"
if [ "$OUT_DIR" == "" ]; then
    msg_error "An explicit output directory is required as the second argument."
    exit 1
fi

if [ ! -d "$OUT_DIR" ]; then
    msg_status "Destination dir $OUT_DIR doesn't exist, creating ..."
    mkdir -p "$OUT_DIR"
fi


################################################################################################
# Mount ESD with shadow file

msg_status "Attach OS X installer image with shadow file ..."

SHADOW_FILE="$TEMP_DIR/shadow"
hdiutil attach "$ESD" -mountpoint "$MNT_ESD" -shadow "$SHADOW_FILE" -nobrowse -owners on


################################################################################################
# Get version

msg_status "Mount BaseSystem ..."

BASE_SYSTEM_DMG="$MNT_ESD/BaseSystem.dmg"
[ ! -e "$BASE_SYSTEM_DMG" ] && msg_error "Could not find BaseSystem.dmg in $MNT_ESD"
hdiutil attach "$BASE_SYSTEM_DMG" -mountpoint "$MNT_BASE_SYSTEM" -nobrowse -owners on

SYSVER_PLIST_PATH="$MNT_BASE_SYSTEM/System/Library/CoreServices/SystemVersion.plist"
DMG_OS_VERS=$(/usr/libexec/PlistBuddy -c 'Print :ProductVersion' "$SYSVER_PLIST_PATH")
DMG_OS_VERS_MAJOR=$(echo $DMG_OS_VERS | awk -F "." '{print $2}')
DMG_OS_VERS_MINOR=$(echo $DMG_OS_VERS | awk -F "." '{print $3}')
DMG_OS_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :ProductBuildVersion' "$SYSVER_PLIST_PATH")
hdiutil detach "$MNT_BASE_SYSTEM"

msg_status "OS X version detected: 10.$DMG_OS_VERS_MAJOR.$DMG_OS_VERS_MINOR, build $DMG_OS_BUILD"


################################################################################################
# Check output doesn't already exist

OUTPUT_DMG="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.dmg"
if [ -e "$OUTPUT_DMG" ]; then
    msg_error "Output file $OUTPUT_DMG already exists! We're not going to overwrite it, exiting ..."
    exit 1
fi


################################################################################################
# Create new basesystem image from existing image

msg_status "Create and Mount new BaseSystem Image ..."

BASESYSTEM_WORKING_IMAGE="$TEMP_DIR/basesystem.dmg"
hdiutil create -o "$BASESYSTEM_WORKING_IMAGE" -size 10g -layout SPUD -fs HFS+J
hdiutil attach "$BASESYSTEM_WORKING_IMAGE" -mountpoint "$MNT_BASE_SYSTEM" -nobrowse -owners on

msg_status "Restore old BaseSystem to new Image ..."

asr restore -source "$BASE_SYSTEM_DMG" -target "$MNT_BASE_SYSTEM" -noprompt -noverify -erase
rm -r "$MNT_BASE_SYSTEM"


################################################################################################
# Copy packages and required files (if needed)

if [ $DMG_OS_VERS_MAJOR -lt 9 ]; then
    MNT_BASE_SYSTEM="/Volumes/Mac OS X Base System"
    BASESYSTEM_OUTPUT_IMAGE="$MNT_ESD/BaseSystem.dmg"
    rm "$BASESYSTEM_OUTPUT_IMAGE"
    PACKAGES_DIR="$MNT_ESD/Packages"
else
    MNT_BASE_SYSTEM="/Volumes/OS X Base System"
    BASESYSTEM_OUTPUT_IMAGE="$OUTPUT_DMG"
    PACKAGES_DIR="$MNT_BASE_SYSTEM/System/Installation/Packages"

    msg_status "Move 'Packages' directory from the ESD to BaseSystem ..."

    rm "$PACKAGES_DIR"
    mv -v "$MNT_ESD/Packages" "$MNT_BASE_SYSTEM/System/Installation/"

    # This isn't strictly required for Mavericks, but Yosemite will consider the
    # installer corrupt if this isn't included, because it cannot verify BaseSystem's
    # consistency and perform a recovery partition verification
    msg_status "Copy original BaseSystem dmg and chunklist ..."

    cp "$MNT_ESD/BaseSystem.dmg" "$MNT_BASE_SYSTEM/"
    cp "$MNT_ESD/BaseSystem.chunklist" "$MNT_BASE_SYSTEM/"
fi


################################################################################################
# Create and add package for automated components

msg_status "Create and add package for automated components ..."

render_template() {
    eval "echo \"$(cat $1)\""
}

CDROM_LOCAL="$MNT_BASE_SYSTEM/private/etc/rc.cdrom.local"
# Sometimes cdrom is disk0, so try both disk0 and disk1
echo "diskutil eraseDisk jhfs+ 'Macintosh HD' GPTFormat disk0" > "$CDROM_LOCAL"
echo "diskutil eraseDisk jhfs+ 'Macintosh HD' GPTFormat disk1" >> "$CDROM_LOCAL"
chmod a+x "$CDROM_LOCAL"
mkdir "$PACKAGES_DIR/Extras"
cp "$SUPPORT_DIR/minstallconfig.xml" "$PACKAGES_DIR/Extras/"
cp "$SUPPORT_DIR/OSInstall.collection" "$PACKAGES_DIR/"

# Build our post-installation pkg that will create a user and enable ssh
# payload items
mkdir -p "$TEMP_DIR/pkgroot/private/var/db/dslocal/nodes/Default/users"
mkdir -p "$TEMP_DIR/pkgroot/private/var/db/shadow/hash"
BASE64_IMAGE=$(openssl base64 -in "$IMAGE_PATH")
# Replace USER and BASE64_IMAGE in the user.plist file with the actual user and image
render_template "$SUPPORT_DIR/user.plist" > "$TEMP_DIR/pkgroot/private/var/db/dslocal/nodes/Default/users/$USER.plist"
USER_GUID=$(/usr/libexec/PlistBuddy -c 'Print :generateduid:0' "$SUPPORT_DIR/user.plist")
# Generate a shadowhash from the supplied password
$SUPPORT_DIR/generate_shadowhash "$PASSWORD" > "$TEMP_DIR/pkgroot/private/var/db/shadow/hash/$USER_GUID"

# postinstall script
mkdir -p "$TEMP_DIR/Scripts"
cat "$SUPPORT_DIR/pkg-postinstall" | sed -e "s/__USER__PLACEHOLDER__/${USER}/" > "$TEMP_DIR/Scripts/postinstall"
chmod a+x "$TEMP_DIR/Scripts/postinstall"

# build it
pkgbuild --quiet \
         --root "$TEMP_DIR/pkgroot" \
         --scripts "$TEMP_DIR/Scripts" \
         --identifier com.vagrantup.veewee-config \
         --version 0.1 \
         "$TEMP_DIR/veewee-config-component.pkg"
productbuild --package "$TEMP_DIR/veewee-config-component.pkg" "$PACKAGES_DIR/veewee-config.pkg"


################################################################################################
# Convert the basesystem image

msg_status "Unmount BaseSystem ..."

hdiutil detach "$MNT_BASE_SYSTEM"

msg_status "Convert BaseSystem to a sparse image ..."

BASESYSTEM_SPARSE_IMAGE="$TEMP_DIR/basesystem.sparseimage"
hdiutil convert "$BASESYSTEM_WORKING_IMAGE" -format UDSP -o "$BASESYSTEM_SPARSE_IMAGE"
rm "$BASESYSTEM_WORKING_IMAGE"

msg_status "Shrink BaseSystem sparse image ..."

hdiutil resize -size `hdiutil resize -limits "$BASESYSTEM_SPARSE_IMAGE" | tail -n 1 | awk '{ print $1 }'`b "$BASESYSTEM_SPARSE_IMAGE"

msg_status "Convert BaseSystem sparse image to a compressed dmg ..."

hdiutil convert "$BASESYSTEM_SPARSE_IMAGE" -format UDZO -o "$BASESYSTEM_OUTPUT_IMAGE"
rm "$BASESYSTEM_SPARSE_IMAGE"


################################################################################################
# Unmount the ESD and convert it if it is the final output (i.e. <= 10.8)

msg_status "Unmount ESD ..."

hdiutil detach "$MNT_ESD"
rm -r "$MNT_ESD"

if [ $DMG_OS_VERS_MAJOR -lt 9 ]; then
    msg_status "Pre-Mavericks we modify the original ESD file ..."

    hdiutil convert -format UDZO -o "$OUTPUT_DMG" -shadow "$SHADOW_FILE" "$ESD"
fi


################################################################################################
# Finalise the output dmg, calculate checksum

if [ -n "$SUDO_UID" ] && [ -n "$SUDO_GID" ]; then
    msg_status "Fix permissions ..."

    chown -R $SUDO_UID:$SUDO_GID "$OUT_DIR"
fi

msg_status "Checksum the output image ..."

MD5=$(md5 -q "$OUTPUT_DMG")
msg_status "MD5: $MD5"

msg_status "Done. Built image is located at $OUTPUT_DMG. Add this iso and its checksum to your template."


################################################################################################
# Cleanup

trap - EXIT INT TERM
cleanup
exit 0
