#!/usr/bin/bash

lsblk --output NAME,TRAN,TYPE,FSTYPE,MOUNTPOINT,STATElsblk --output NAME,TRAN,TYPE,FSTYPE,MOUNTPOINT,STATE | grep 'NAME\|crypt\|disk\|loop'
read -p "$(echo -e "\n? disk device name [/dev/sda1]: ")" disk_device_name;
read -p "$(echo -e "\n? tang service address [ip-address:port]:")" tang_service_address;
sudo clevis luks bind -d ${disk_device_name} tang '{"url": "http://'${tang_service_address}'"}'; returnCode=${?}
echo -e "[INFO] return code: ${returnCode}"
echo "[INFO] done."
