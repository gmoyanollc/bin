# !/usr/bin/bash
# unlock-partition.sh
lsblk --output NAME,TRAN,TYPE,MOUNTPOINT,STATE
device=$(zenity --entry= --entry-text="" --text="[sd[a-z][n]] [loop[n]]")
echo "[INFO] unlocking partition at block device /dev/${device}..."
sudo clevis luks unlock -d /dev/${device}
echo "[INFO] return code: ${?}"
if [[ ${?} -gt 0 ]] && [[ $(echo ${device} | grep -i loop) ]]; then
  "[INFO] releasing loop block device /dev/${device} ..."
  sudo losetup -d /dev/${device}
fi
echo "[INFO] done."
read

