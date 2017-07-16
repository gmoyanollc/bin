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
system_mount_point="/run/media"
green="\033[32m"
black="\033[0m"

if [ "$1" == "" ]; 
then
  find ${HOME} -maxdepth 1 -type d 
  read -p "$(echo -e ${green}"? disk dir path: "${black})" disk_dir;
else
  disk_dir="$1"
fi
if [ -d "${disk_dir}" ];
then
  ls -1 ${disk_dir}
else
  echo "Error: ${disk_dir} could not be found!"
  exit 1
fi
read -p "$(echo -e ${green}"? disk name (exclude '.img.disk' suffix): "${black})" disk_name;
if [ -f "${disk_dir}/${disk_name}.img.disk" ];
then
  ls -1 "${disk_dir}/${disk_name}.img.disk"
else
  echo "Error: ${disk_dir}/${disk_name}.img.disk could not be found!"
  exit 1
fi
set -x
#}
#// gCOMMENT
#disk_name=$1
#// gMODIFY
#MOUNT_POINT=$2
MOUNT_POINT=${system_mount_point}/${USER}/${disk_name}
#// gINSERT {
set +x
find ${system_mount_point}/${USER}/* -maxdepth 2 -type d
read -p "$(echo -e ${green}"? key dir ('n/a' for no key): "${black})" key_dir;
if [ "${key_dir}" == "n/a" ];
then 
  no_key=0
else
  if [ -d "${key_dir}" ];
  then
    eval "ls -1 '${key_dir}'"
  else
    echo "Error: ${key_dir} could not be found!"
    exit 1
  fi
  read -p "$(echo -e ${green}"? key name (exclude '.gpg' suffix): "${black})" key_name;
  if [ -f "${key_dir}/${key_name}.gpg" ];
  then
    ls -1 "${key_dir}/${key_name}.gpg"
    key_file=${key_dir}/${key_name}.gpg
  else
    echo "Error: ${key_dir}/${key_name}.gpg could not be found!"
    exit 1
  fi
  read -p "$(echo -e ${green}"? pin name (exclude '.gpg' suffix): "${black})" pin_name;
  if [ -f "${key_dir}/${pin_name}.gpg" ];
  then
    ls -1 "${key_dir}/${pin_name}.gpg"
    pin_file=${key_dir}/${pin_name}.gpg
    #// gCOMMENT neither of the following works for path containing space character
    #cypher="$(gpg -q -d ${pin_file})"
    #cypher=eval "gpg -q -d '${pin_file}'"
    # disable the ui prompt
    cypher="$(GPG_AGENT_INFO='' gpg -q -d ${pin_file})"
  else
    echo "Error: ${key_dir}/${pin_name}.gpg could not be found!"
    exit 1
  fi
fi
#// }
#// gCOMMENT {
#if [ ! -f "${key_file}" ];
#then
#    echo "Error: ${key_file} could not be found!"
#    exit 1
#fi
#if [ ! -n "$disk_name" ];
#then
#    echo "Usage: $0 disk-name [mount-point] <auto>"
#    exit 1
#fi
#if [ ! -n "$MOUNT_POINT" ];
#then
#    echo "Warning: No MOUNT_POINT env var set. Using $HOME/mounted-$disk_name"
#    MOUNT_POINT="$HOME/mounted-$disk_name"
#fi
#if [ ! -f "${disk_dir}/$disk_name.disk" ];
#then
#    echo "Error: $disk_name could not be found!"
#    exit 1
#fi
# }
# gCOMMENT {
#if [ ! -f "disks/$disk_name.key.gpg" ];
#then
#    echo "Error: Key for $disk_name could not be found!"
#    exit 1
#fi
#// }
#// gMODIFY
#if [ -f "disks/$disk_name.mounted" ];
if [ -f "${disk_dir}/$disk_name.mounted" ];
then
  if [ "$3" == "auto" ];
  then
    exit 0
  else
    #// gMODIFY
    #echo "Error: Disk $disk_name is already mounted!"
    echo "Warning: Disk $disk_name may already be mounted!"
    #// gINSERT {
    read -p "$(echo -e ${green}"? ignore (y/n): "${black})" ignore;
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
# gCOMMENT to test for a return code on decryption failure
#set -e
# Print every step we execute
set -x
# Do it
LO_MOUNT=`losetup -f`
VG_MOUNT=`date +%s | sha1sum | head -c 8`
#// gMODIFY
#sudo losetup $LO_MOUNT "disks/$disk_name.disk"
sudo losetup $LO_MOUNT "${disk_dir}/$disk_name.img.disk"
#// gINSERT
DECRYPT_ERROR=false

until [ ${DECRYPT_ERROR} == "false" ]; do
  echo decrypting...
  #// gMODIFY
  #// gCOMMENT asymmetric encryption
  #gpg --no-default-keyring --secret-keyring keyrings/secret.gpg --keyring keyrings/public.gpg --trustdb-name keyrings/trustdb.gpg --decrypt "disks/$disk_name.key.gpg" | sudo cryptsetup luksOpen $LO_MOUNT $VG_MOUNT -d -
  if [ ${no_key} ];
  then 
    sudo cryptsetup --key-file - create $VG_MOUNT $LO_MOUNT
    echo "return code: $?"
  else
    #read -p "$(echo -e ${green}"? cypher: "${black})" cypher;
    eval "gpg -q -d '${key_file}'" | sudo cryptsetup ${cypher} --key-file - create $VG_MOUNT $LO_MOUNT; (echo "return code: ${?}")
    #// gCOMMENT test for return code 0 to continue, other prompt for loop
  fi
  #// gCOMMENT symmetric encryption
  #sudo cryptsetup create $VG_MOUNT $LO_MOUNT
  #// gINSERT
  sudo cryptsetup status $VG_MOUNT
  sudo mount /dev/mapper/$VG_MOUNT "$MOUNT_POINT"
  echo "return code: $?"
  #// gCOMMENT return code 32 is thrown when the wrong key file is applied to decryption
  [ ${?} != 0 ] && ${DECRYPT_ERROR}=true
done

#// gMODIFY
#echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"disks/$disk_name.mounted"
echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"${disk_dir}/$disk_name.mounted"
#// gINSERT
sudo chown -R "$USER:$USER" "$MOUNT_POINT"
sudo -k

