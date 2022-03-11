# !/usr/bin/bash
# unlock-partition.sh
# to-do

# [INFO] return code: 5
# [INFO] clevis unlock result: Error communicating with the server!
# Device luks-f86008e7-f64e-4ce2-8302-12b7c379794f already exists.
# [TEST] grep luks volume name: Error communicating with the server! Device luks-f86008e7-f64e-4ce2-8302-12b7c379794f already exists.

# error 5 can be fixed with the following:
# when usb device is mounted
# sudo umount "${MOUNT_POINT}"
# sudo cryptsetup close luks-f86008e7-f64e-4ce2-8302-12b7c379794f
#
# when usb device looses its mount and will not remount:
# sudo dmsetup remove luks-b27bf382-a17c-4696-ab19-8a3778d5dd0c
# 

#set -x
lsblk --output NAME,TRAN,TYPE,FSTYPE,MOUNTPOINT,STATE | grep "NAME\|crypt\|disk\|loop"
echo -e "\n[PROMPT] Enter 'NAME' for 'FSTYPE': 'crypto_LUKS' without a 'MOUNTPOINT' path.\n"
device=$(zenity --entry= --entry-text="" --text="[sd[a-z][n]] [loop[n]]")
echo "[INFO] unlocking partition at block device /dev/${device}..."
clevisUnlockResult=$((sudo clevis luks unlock -d /dev/${device}) 2>&1) 
clevisUnlockReturnCode=${?}
echo "[INFO] return code: ${clevisUnlockReturnCode}"
echo "[INFO] clevis unlock result: ${clevisUnlockResult}"
luksName=$(echo ${clevisUnlockResult} | grep -o 'luks[a-z0-9\-]*')
if [[ ${clevisUnlockReturnCode} -gt 0 ]] && [[ $(echo ${device} | grep -i loop) ]]; then
  echo "[INFO] releasing loop block device /dev/${device} to try again..."
  sudo losetup -d /dev/${device}
fi
if [[ ${clevisUnlockReturnCode} -eq 5 ]] && [[ $(echo ${clevisUnlockResult} | grep luks) ]]; then
  echo "[INFO] closing luks volume ${luksName} to try again..."
  sudo cryptsetup close ${luksName}
fi
if [ ${clevisUnlockReturnCode} -eq 0 ]; then
  lsblk --output NAME,TRAN,TYPE,FSTYPE,MOUNTPOINT,STATE | grep -A 1 ${device}
fi
echo -e "[INFO] done.....................................................................\n"


