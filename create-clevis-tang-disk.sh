FILE_NAME=${1}
IMAGE_SIZE=${2}GB
IMAGE_FILE=${FILE_NAME}.img
fallocate -l ${IMAGE_SIZE} ${IMAGE_FILE}
# fallocate -l 1G test.img
cryptsetup -y luksFormat ${IMAGE_FILE}
# sudo cryptsetup -y luksFormat test.img
DEVICE_LOOP=`losetup -f`
sudo losetup ${DEVICE_LOOP} ${IMAGE_FILE} 
# sudo losetup ${DEVICE_LOOP} test.img
LUKS_NAME=`date +%s | sha1sum | head -c 8`
sudo cryptsetup open ${DEVICE_LOOP} ${LUKS_NAME}
# sudo cryptsetup open ${DEVICE_LOOP} ${LUKS_NAME}
sudo mkfs.ext4 /dev/mapper/${LUKS_NAME} -L ${FILE_NAME}
# sudo mkfs.ext4 /dev/mapper/${LUKS_NAME} -L test

# manual mount or `gnome-disk-image-mounter --writable`
sudo mkdir ${MOUNT-PATH}${FILE_NAME}
# mkdir ~/test
sudo mount /dev/mapper/${LUKS_NAME} ${MOUNT-PATH}${FILE_NAME}
# sudo mount /dev/mapper/${LUKS_NAME} ~/test

# persist user permissions
sudo chown -R ${USER}:${USER} ${MOUNT-PATH}${FILE_NAME}
# sudo chown -R userJoe:userJoe ~/test 
sudo clevis luks bind -d ${DEVICE_LOOP} tang '{"url":"${TANG_URL}"}'
# sudo clevis luks bind -d /dev/loop0 tang '{"url":"http://tang.server:9999"}'

# hereafter, run the following scripts to mount disk using clevis
# 
# $ gnome-disk-image-mounter-rw.sh 
# $ unlock-partition.sh

