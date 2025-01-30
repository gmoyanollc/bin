LS_BLK_NAME=${1};
TANG_IP_PORT_ADDRESS=${2};
lsblk
sudo clevis luks bind -d /dev/${LS_BLK_NAME} tang '{"url":"http://'${TANG_IP_PORT_ADDRESS}'"}';
