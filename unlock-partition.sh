# !/usr/bin/bash
# unlock-partition.sh
lsblk
device=$(zenity --entry= --entry-text="" --text="[sd[a-z][n]] [loop[n]]")
echo "[INFO] unlocking partition /dev/${device}..."
sudo clevis luks unlock -d ${device}
echo "[INFO] done, return code: ${?}"
read

