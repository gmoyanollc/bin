#!/usr/bin/bash

# MIT License
#
# Copyright (c) 2017 George Moyano (https://onename.com/gmoyano)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# source: https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key

USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
GREEN="\033[32m"
BLACK="\033[0m"
REG_EXP_INT="[0-9]+"

dirOk=false

while [ "${dirOk}" == "false" ]; do
  if [ "${1}" == "" ]; then
    find "${HOME}" -maxdepth 1 -type d 
    find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
    read -p "$(echo -e ${GREEN}"? new disk dir path: "${BLACK})" disk_dir;
  else
    key_dir="${1}"
  fi
  if [ -d "${disk_dir}" ]; then
    dirOk=true
    ls -1d "${disk_dir}"
  else
    echo -e "\n  [ERROR] Directory ${disk_dir} could not be found!\n"
    read -p "  Press any key to try again.";
    set -- "${@:1}" ""
    #exit 1
  fi
done

read -p "$(echo -e ${GREEN}"? new disk name (exclude '.img.disk' suffix): "${BLACK})" disk_name;
dirOk=false

while [ "${dirOk}" == "false" ]; do
  find "${SYSTEM_MOUNT_POINT}/${USER}" -maxdepth 2 -type d
  read -p "$(echo -e ${GREEN}"? key dir path: "${BLACK})" key_dir
  if [ -d "${key_dir}" ]; then
    dirOk=true
    ls -1 "${key_dir}"
  else
    echo -e "\n  [ERROR] Directory ${key_dir} could not be found!\n"
    read -p "  Press any key to try again.";
    #exit 1
  fi
done

fileOk=false

while [ "${fileOk}" == "false" ]; do
  read -p "$(echo -e ${GREEN}"? key name: "${BLACK})" key_name
  if [ -f "${key_dir}/${key_name}" ];
  then
    fileOk=true
    ls -1 "${key_dir}/${key_name}"
  else
    echo "\n  [ERROR] ${key_dir}/${key_name} could not be found!\n"
    #exit 1;
  fi
done

fileSizeOk=false

while [ "${fileSizeOk}" == "false" ]; do
  read -p "$(echo -e ${GREEN}"? file size in gigabytes (exclude 'G' suffix): "${BLACK})" file_size
#  if ! [[ "${file_size}" =~ (${REG_EXP_INT}) ]]; then
  if [[ "${file_size}" =~ (${REG_EXP_INT}) ]]; then
    fileSizeOk=true
    echo "  [INFO] matched integer: ${BASH_REMATCH[1]}, ${file_size}"
  else
    echo "  [ERROR] not an integer: ${file_size}"
    #exit 1
  fi
done

set -x
new_disk_file=${disk_dir}/${disk_name}.img.disk
key_file=${key_dir}/${key_name}
file_size=${file_size}
#// gINSERT source: https://wiki.centos.org/HowTos/EncryptedFilesystem {
# Create an empty file...
# ...a sparse file...no
# real blocks are written. Since we will force block allocation
# later on, it would not make much sense to do this now, since
# the blocks will be rewritten anyway.
# }
#// gMODIFY
#dd of=/path/to/secretfs bs=1G count=0 seek=8
dd of=${new_disk_file} bs=1G count=0 seek=${file_size} status=progress
# Lock down normal access to the file
#chmod 600 /path/to/secretfs
# Associate a loopback device with the file
# gINSERT {
LO_MOUNT=`losetup -f`
VG_MOUNT=`date +%s | sha1sum | head -c 8`
mount_point="${SYSTEM_MOUNT_POINT}/${USER}/${disk_name}"
#}
# gMODIFY
#losetup /dev/loop0 /path/to/secretfs
sudo losetup ${LO_MOUNT} ${new_disk_file} ; returnCode=${?}
#// gINSERT
if [ ! ${returnCode} == 0 ]; then
  echo "  WARNING: return code: ${?}"
fi
# Encrypt storage in the device. cryptsetup will use the Linux
# device mapper to create, in this case, /dev/mapper/secretfs.
# The -y option specifies that you'll be prompted to type the
# passphrase twice (once for verification).
#cryptsetup -y create secretfs /dev/loop0
# gINSERT {
# source: https://wiki.gentoo.org/wiki/Sakaki%27s_EFI_Install_Guide/Preparing_the_LUKS-LVM_Filesystem_and_Boot_USB_Key
# derived from 
#eval "gpg -q -d '${key_file}'" | sudo cryptsetup --cipher serpent-xts-plain64 --key-size 512 --hash sha512 --key-file - create ${VG_MOUNT} ${LO_MOUNT}
gpg -q -d "${key_file}" | sudo cryptsetup --cipher serpent-xts-plain64 --key-size 512 --hash sha512 --key-file - create ${VG_MOUNT} ${LO_MOUNT} ; returnCode=${?}
if [ ! ${returnCode} == 0 ]; then
  echo "  ERRROR - return code: ${returnCode}"
  exit ${returnCode}
fi
# }
# Or, if you want to use LUKS, you should use the following two
# commands (optionally with additional) parameters. The first
# command initializes the volume, and sets an initial key. The
# second command opens the partition, and creates a mapping
# (in this case /dev/mapper/secretfs).
# gMODIFY {
#cryptsetup -y luksFormat /dev/loop0
#cryptsetup luksOpen /dev/loop0 secretfs
#cryptsetup -y luksFormat ${LO_MOUNT}
#cryptsetup luksOpen ${LO_MOUNT} ${new_disk_file}
# }
# Check its status (optional)
# gMODIFY
#cryptsetup status secretfs
sudo cryptsetup status ${VG_MOUNT}
# Now, we will write zeros to the new encrypted device. This
# will force the allocation of data blocks. And since the zeros
# are encrypted, this will look like random data to the outside
# world, making it nearly impossible to track down encrypted
# data blocks if someone gains access to the file that holds
# the encrypted filesystem.
# gMODIFY
#dd if=/dev/zero of=/dev/mapper/secretfs
sudo dd if=/dev/zero of=/dev/mapper/${VG_MOUNT} status=progress ; returnCode=${?}
# gINSERT {
if [ ! ${returnCode} == 0 ]; then
  echo "  WARNING: return code: ${returnCode}"
fi
# }
# Create a filesystem and verify its status
#// gMODIFY
#mke2fs -j -O dir_index /dev/mapper/secretfs
#// gCOMMENT
#tune2fs -l /dev/mapper/secretfs
# gINSERT {
# source: https://forums.opensuse.org/showthread.php/495891-Encrypted-ext4-partition-corrupted-Recovery-possible
#   "ext4 is journeled and that adds read writes and can reduce the live of flash memory"
#    ext4 filesystem threw errors: "Bad magic number in super-block"
# source: https://patrick.uiterwijk.org/blog/2013/2/25/gpg-encrypted-loopback-disks 
#    createdisk.sh
sudo mkfs.ext3 /dev/mapper/${VG_MOUNT} -L ${disk_name} ; returnCode=${?}
if [ ! ${returnCode} == 0 ]; then
  echo "  ERROR - return code: ${returnCode}"
  exit ${returnCode}
fi
# }
# Mount the new filesystem in a convenient location
#// gMODIFY
#mkdir /mnt/cryptofs/secretfs
sudo mkdir "${SYSTEM_MOUNT_POINT}/${USER}/${disk_name}"
# gINSERT {
if [ ! ${returnCode} == 0 ]; then
  echo "  WARNING - return code: ${returnCode}"
fi
# }
#// gMODIFY
# mount /dev/mapper/secretfs /mnt/cryptofs/secretfs
sudo mount /dev/mapper/${VG_MOUNT} ${mount_point} ; returnCode=${?}
#// gINSERT
if [ ! ${returnCode} == 0 ]; then
  echo "  ERROR - return code: ${?}"
  exit ${returnCode}
fi
#// gMODIFY
#echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"disks/$disk_name.mounted"
echo "$LO_MOUNT:$VG_MOUNT:${mount_point}" > "${new_disk_file}.mounted"
#// gINSERT
sudo chown -R "$USER:$USER" "${mount_point}"
sudo -k

