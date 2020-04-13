# !/usr/bin/bash
# unlock-partition.sh
lsblk --output NAME,TRAN,TYPE,MOUNTPOINT,STATE
device=$(zenity --entry= --entry-text="" --text="[sd[a-z][n]] [loop[n]]")
echo "[INFO] unlocking partition /dev/${device}..."
sudo clevis luks unlock -d /dev/${device}
echo "[INFO] done, return code: ${?}"
read

