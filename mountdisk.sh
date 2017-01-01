#!/usr/bin/bash
# Copyright (c) 2013, Patrick Uiterwijk <patrick@uiterwijk.org>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
# 
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# // gINSERT { 
# // Original source: https://patrick.uiterwijk.org/blog/2013/2/25/gpg-encrypted-loopback-disks
# //
# // Copyright (2016), [George Moyano](https://onename.com/gmoyano)
# // All rights reserved.
# //
# // Source code lines and blocks preceded by the characters "// g" are contributions 
# // by George Moyano.  Such contributions are copyrighted source held and licensed by 
# // George Moyano under the aforementioned terms.
# }

# Configuration
#// gINSERT {
SYSTEM_MOUNT_POINT="/run/media"
GREEN="\033[32m"
BLACK="\033[0m"

find ../* -maxdepth 0 -type d
read -p "$(echo -e ${GREEN}"? disk dir path: "${BLACK})" DISK_DIR;
if [ -d "${DISK_DIR}" ];
then
  ls -1 ${DISK_DIR}
else
  echo "Error: ${DISK_DIR} could not be found!"
  exit 1
fi
read -p "$(echo -e ${GREEN}"? disk name (exclude '.disk' suffix): "${BLACK})" DISK_NAME;
if [ -f "${DISK_DIR}/${DISK_NAME}.disk" ];
then
  ls -1 "${DISK_DIR}/${DISK_NAME}.disk"
else
  echo "Error: ${DISK_DIR}/${DISK_NAME}.disk could not be found!"
  exit 1
fi
set -x
#}
#// gCOMMENT
#DISK_NAME=$1
#// gMODIFY
#MOUNT_POINT=$2
MOUNT_POINT=${SYSTEM_MOUNT_POINT}/${USER}/${DISK_NAME}
#// gINSERT {
set +x
find ${SYSTEM_MOUNT_POINT}/${USER}/* -maxdepth 0 -type d
read -p "$(echo -e ${GREEN}"? key disk mount path: "${BLACK})" KEY_DISK_MOUNT;
if [ -d "${KEY_DISK_MOUNT}" ];
then
  find ${KEY_DISK_MOUNT}/* -maxdepth 0 -type d
else
  echo "Error: ${KEY_DISK_MOUNT} could not be found!"
  exit 1
fi
read -p "$(echo -e ${GREEN}"? key dir: "${BLACK})" KEY_DIR;
if [ -d "${KEY_DIR}" ];
then
  ls -1 "${KEY_DIR}"
else
  echo "Error: ${KEY_DIR} could not be found!"
  exit 1
fi
read -p "$(echo -e ${GREEN}"? key name: "${BLACK})" KEY_NAME;
if [ -f "${KEY_DIR}/${KEY_NAME}" ];
then
  ls -1 "${KEY_DIR}/${KEY_NAME}"
else
  echo "Error: ${KEY_DIR}/${KEY_NAME} could not be found!"
  exit 1
fi
set +x
#// }
#// gCOMMENT {
#if [ ! -f "${key_file}" ];
#then
#    echo "Error: ${key_file} could not be found!"
#    exit 1
#fi
#if [ ! -n "$DISK_NAME" ];
#then
#    echo "Usage: $0 disk-name [mount-point] <auto>"
#    exit 1
#fi
#if [ ! -n "$MOUNT_POINT" ];
#then
#    echo "Warning: No MOUNT_POINT env var set. Using $HOME/mounted-$DISK_NAME"
#    MOUNT_POINT="$HOME/mounted-$DISK_NAME"
#fi
#if [ ! -f "${DISK_DIR}/$DISK_NAME.disk" ];
#then
#    echo "Error: $DISK_NAME could not be found!"
#    exit 1
#fi
# }
# gCOMMENT {
#if [ ! -f "disks/$DISK_NAME.key.gpg" ];
#then
#    echo "Error: Key for $DISK_NAME could not be found!"
#    exit 1
#fi
#// }
#// gMODIFY
#if [ -f "disks/$DISK_NAME.mounted" ];
if [ -f "${DISK_DIR}/$DISK_NAME.mounted" ];
then
  if [ "$3" == "auto" ];
  then
    exit 0
  else
    #// gMODIFY
    #echo "Error: Disk $DISK_NAME is already mounted!"
    echo "Warning: Disk $DISK_NAME may already be mounted!"
    #// gINSERT {
    read -p "$(echo -e ${GREEN}"? ignore (y/n): "${BLACK})" ignore;
    if [ ${ignore} == "y" ];
    then
      echo "ignored"
    else
    #// }
      exit 1
    #// gINSERT
    fi
  fi
fi
if [ -f "$MOUNT_POINT" ];
then
    echo "Error: $MOUNT_POINT already exists!"
    exit 1
fi
sudo mkdir "$MOUNT_POINT"
# Fail on error
set -e
# Print every step we execute
set -x
# Do it
LO_MOUNT=`losetup -f`
VG_MOUNT=`date +%s | sha1sum | head -c 8`
#// gMODIFY
#sudo losetup $LO_MOUNT "disks/$DISK_NAME.disk"
sudo losetup $LO_MOUNT "${DISK_DIR}/$DISK_NAME.disk"
#// gINSERT
echo decrypting...
#// gMODIFY
#// gCOMMENT asymmetric encryption
#gpg --no-default-keyring --secret-keyring keyrings/secret.gpg --keyring keyrings/public.gpg --trustdb-name keyrings/trustdb.gpg --decrypt "disks/$DISK_NAME.key.gpg" | sudo cryptsetup luksOpen $LO_MOUNT $VG_MOUNT -d -
gpg -q -d ${KEY_DIR}/${KEY_NAME} | sudo cryptsetup --key-file - create $VG_MOUNT $LO_MOUNT
#// gCOMMENT symmetric encryption
#sudo cryptsetup create $VG_MOUNT $LO_MOUNT
#// gINSERT
sudo cryptsetup status $VG_MOUNT
sudo mount /dev/mapper/$VG_MOUNT "$MOUNT_POINT"
#// gMODIFY
#echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"disks/$DISK_NAME.mounted"
echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"${DISK_DIR}/$DISK_NAME.mounted"
#// gINSERT
sudo chown -R "$USER:$USER" "$MOUNT_POINT"
sudo -k

