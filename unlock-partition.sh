# !/usr/bin/bash
# unlock-partition.sh
lsblk
device=$(zenity --entry= --entry-text="/dev/sdb1" --text="/dev/sdb1")
echo "[INFO] unlocking partition ${device}..."
sudo clevis luks unlock -d ${device}
echo "[INFO] done."
read

