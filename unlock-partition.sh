# !/usr/bin/bash
# unlock-partition.sh
lsblk
device=$(zenity --entry= --entry-text="/dev/sdb1" --text="/dev/sdb1")
sudo clevis luks unlock -d ${device}


