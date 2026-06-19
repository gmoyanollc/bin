lsblk
read -p "enter device, e.g., /dev/sdb1 : " device
echo device=${device}
umount -v ${device}
sudo mkfs.exfat -V ${device}
