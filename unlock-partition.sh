# !/usr/bin/bash
# unlock-partition.sh
# to-do
# error 5 can be fixed with the following command:
# sudo cryptsetup close luks-f86008e7-f64e-4ce2-8302-12b7c379794f
# haven't seen error 5 but do get this:
# [INFO] clevis unlock result: Error communicating with the server!
# Device luks-f86008e7-f64e-4ce2-8302-12b7c379794f already exists.
# [INFO] return code: 0
# moved return code to see if different when it follows right after

lsblk --output NAME,TRAN,TYPE,MOUNTPOINT,STATE
device=$(zenity --entry= --entry-text="" --text="[sd[a-z][n]] [loop[n]]")
echo "[INFO] unlocking partition at block device /dev/${device}..."
clevisUnlockResult=$((sudo clevis luks unlock -d /dev/${device}) 2>&1) 
echo "[INFO] return code: ${?}"
echo "[INFO] clevis unlock result: ${clevisUnlockResult}"
luksName=$(echo ${clevisUnlockResult} | grep -w 'luks')
echo "[TEST] grep luks volume name: ${luksName}"
if [[ ${?} -gt 0 ]] && [[ $(echo ${device} | grep -i loop) ]]; then
  "[INFO] releasing loop block device /dev/${device} to try again..."
  sudo losetup -d /dev/${device}
fi
if [[ ${?} -eq 5 ]] && [[ $(echo ${?} | grep luks) ]]; then
  "[INFO] closing luks volume $(echo ${?} | grep -o luks) to try again..."
  sudo cryptsetup close $(echo ${?} | grep -i luks)
fi
echo "[INFO] done."
read

