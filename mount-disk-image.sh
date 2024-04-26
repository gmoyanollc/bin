# /bin/bash
unusedDevice=$(sudo losetup -f)
gnome-disk-image-mounter --writable ${1}
~/bin/unlock-partition.sh ${unusedDevice}
