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

#// gINSERT source: https://patrick.uiterwijk.org/blog/2013/2/25/gpg-encrypted-loopback-disks

# Configuration
#// gINSERT {
#set -x
#DISK_DIR="g-disk"
USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
dirOk=false

while [ ${dirOk} == "false" ]; do
  if [ "${1}" == "" ]; then
    find "${HOME}" -maxdepth 1 -type d 
    find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
    read -p "$(echo -e ${green}"? disk dir path: "${black})" disk_dir;
  else
    disk_dir="${1}"
  fi
  if [ -d "${disk_dir}" ]; then
    dirOk=true
    ls -1 ${disk_dir}
  else
    echo -e "\nERROR: directory ${disk_dir} could not be found!\n"
    set -- "" "${@:2}"
  fi
done

fileOk=false

while [ ${fileOk} == "false" ]; do
  if [ "${2}" == "" ]; then
    read -p "$(echo -e ${green}"? disk file: "${black})" disk_name;
  else
    disk_name="${2}"
  fi
  if [ -f "${disk_dir}/${disk_name}" ]; then
    fileOk=true
    ls -1 "${disk_dir}/${disk_name}"
  else
    echo -e "\nERROR: file ${disk_dir}/${disk_name} could not be found!\n"
    set -- "${@:1}" ""
  fi
done

#// gCOMMENT-OUT {
#set +x
#if [ ! -n "$DISK_NAME" ];
#then
#    echo "Usage: $0 disk-name"
#    exit 1
#fi
#// gCOMMENT-OUT }
# Fail on error
set -e
# Print all commands on execution
#// gCOMMENT
#set -x
# Get disk info
#// gMODIFY
#if [ ! -f "disks/$DISK_NAME.mounted" ];
if [ ! -f "${disk_dir}/$disk_name.mounted" ];
then
    echo "Disk ${disk_name} was not mounted!"
    exit -1
fi
#// gINSERT
set -x
#// gMODIFY
#MOUNT_INFO="`cat "disks/$DISK_NAME.mounted"`"
MOUNT_INFO="`cat "${disk_dir}/${disk_name}.mounted"`"
LO_MOUNT="`echo ${MOUNT_INFO} | awk -F":" '{print $1}'`"
VG_MOUNT="`echo ${MOUNT_INFO} | awk -F":" '{print $2}'`"
MOUNT_POINT="`echo ${MOUNT_INFO} | awk -F":" '{print $3}'`"
unmountOk=false

while [ ${decryptOk} == "false" ]; do
  sudo umount "${MOUNT_POINT}" ; returnCode=${?}
  if [ ${returnCode} == 0 ]; then
    unmountOk=true
  else
    echo "  ERROR: unmount failure"
  fi
done

# gMODIFY
#sudo cryptsetup luksClose /dev/mapper/$VG_MOUNT
sudo cryptsetup close /dev/mapper/${VG_MOUNT}
sudo losetup --detach ${LO_MOUNT}
#// gMODIFY
#rm -f "disks/$DISK_NAME.mounted"
rm -f "${disk_dir}/${disk_name}.mounted"
sudo rmdir "${MOUNT_POINT}"
sudo -k
