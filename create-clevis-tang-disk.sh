#!/bin/bash -vx
MOUNT_PATH="/run/media"
FILE_NAME=${1}
IMAGE_SIZE=${2}GB
IMAGE_FILE=${FILE_NAME}.img
echo FILE_NAME: ${FILE_NAME}
echo IMAGE_SIZE: ${IMAGE_SIZE}
echo IMAGE_FILE: ${IMAGE_FILE}
echo MOUNT_PATH: ${MOUNT_PATH}
echo USER: ${USER}
echo 
echo "Enter TANG_URL server-ip:port-number"
read TANG_URL_IP_PORT
TANG_URL=http://${TANG_URL_IP_PORT}
echo TANG_URL: ${TANG_URL}
echo "Enter to start or ctrl-c to quit"
read
(set -x; fallocate -l ${IMAGE_SIZE} ${IMAGE_FILE}) 
# fallocate -l 1G test.img
if [ "${?}" = "0" ]; then
  (set -x; ls -al ${IMAGE_FILE})
else  
  exit ${?} 
esle
fi
TRY=true

while [ "${TRY}" = "true" ]; do
  (set -x; cryptsetup -y luksFormat ${IMAGE_FILE})
  # sudo cryptsetup -y luksFormat test.img
  RETURN_CODE="${?}"
  if [ "${RETURN_CODE}" = "0" ]; then
    (set -x; sudo cryptsetup status ${IMAGE_FILE})
    TRY=false
  elif [ "${RETURN_CODE}" != "2" ]; then # not a passphrase problem
    exit ${RETURN_CODE}
  fi
done

DEVICE_LOOP=`losetup -f`
echo DEVICE_LOOP: ${DEVICE_LOOP}
(set -x; sudo losetup ${DEVICE_LOOP} ${IMAGE_FILE}) 
# sudo losetup ${DEVICE_LOOP} test.img
#LUKS_NAME=`date +%s | sha1sum | head -c 8`
LUKS_NAME=${FILE_NAME}
echo LUKS_NAME: ${LUKS_NAME}
(set -x; sudo cryptsetup open ${DEVICE_LOOP} ${LUKS_NAME})
# sudo cryptsetup open ${DEVICE_LOOP} ${LUKS_NAME}
(set -x; sudo mkfs.ext4 /dev/mapper/${LUKS_NAME} -L ${IMAGE_FILE})
# sudo mkfs.ext4 /dev/mapper/${LUKS_NAME} -L test
(set -x; sudo clevis luks bind -d ${DEVICE_LOOP} tang '{"url":"'${TANG_URL}'"}')
# sudo clevis luks bind -d /dev/loop0 tang '{"url":"http://tang.server:9999"}'
# manual mount with user permissions
(set -x; sudo mkdir ${MOUNT_PATH}/${USER}/${FILE_NAME})
# mkdir ~/test
(set -x; sudo mount /dev/mapper/${LUKS_NAME} "${MOUNT_PATH}/${USER}/${FILE_NAME}")
# sudo mount /dev/mapper/${LUKS_NAME} ~/test
# persist user permissions
(set -x; sudo chown -R ${USER}:${USER} "${MOUNT_PATH}/${USER}/${FILE_NAME}")
# sudo chown -R userJoe:userJoe ~/test 

# hereafter, run the following to mount disk using clevis
# 
# $ gnome-disk-image-mounter-rw.sh 
# $ unt lock-partition.sh

echo "done...disk created and mounted at ${MOUNT_PATH}/${USER}/${FILE_NAME}"
