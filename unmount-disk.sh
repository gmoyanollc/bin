#!/usr/bin/bash

if [[ ${#} = 0 ]]; then
  set -- --help # set arg[1]
fi
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -dn|--disk-name)
      DISK_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -dd|--disk-dir)
      DISK_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      echo "usage: -dn|--disk-name [disk-name] -dd|--disk-dir [disk-dir]"
      exit 0 
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=('$1') # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ -z "${DISK_NAME}" ]; then
  DISK_NAME=disk-name
  DEFAULT=true
fi
if [ -z "${DISK_DIR}" ]; then
  DISK_DIR=disk-dir
  DEFAULT=true
fi
if [ "${DEFAULT}" = "true" ]; then
  echo -e "\ndefault applied where not specified"
fi

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
USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
IS_FILE=false

while [ ${IS_FILE} == "false" ]; do
  if [ -f "${DISK_DIR}/${DISK_NAME}" ]; then
    IS_FILE=true
    (set -x; ls -1 "${DISK_DIR}/${DISK_NAME}")
  else
    echo -e "\nERROR: file ${DISK_DIR}/${DISK_NAME} could not be found!\n"
    find "${HOME}" -maxdepth 1 -type d
    find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
    read -p "$(echo -e ${green}"? disk dir path: "${black})" DISK_DIR;

    while [ ${IS_FILE} == "false" ]; do
      if [ -f "${DISK_DIR}/${DISK_NAME}" ]; then
        IS_FILE=true
        (set -x; ls -1 "${DISK_DIR}/${DISK_NAME}")
      elif [ -d "${DISK_DIR}" ]; then
        (set -x; ls -1 "${DISK_DIR}")
      else
        echo -e "\nERROR: directory ${disk_dir} could not be found!\n"
      fi
      read -p "$(echo -e ${green}"? disk name: "${black})" DISK_NAME;
    done

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
#set -e
# Print all commands on execution
#// gCOMMENT
#set -x
# Get disk info
echo "${DISK_DIR}/$DISK_NAME.mounted" ;
if [ ! -f "${DISK_DIR}/$DISK_NAME.mounted" ];
then
    echo "Disk ${DISK_NAME} was not mounted!"
    exit -1
fi
#// gMODIFY
#MOUNT_INFO="`cat "disks/$DISK_NAME.mounted"`"
MOUNT_INFO="`cat "${DISK_DIR}/${DISK_NAME}.mounted"`"
LO_MOUNT="`echo ${MOUNT_INFO} | awk -F":" '{print $1}'`"
VG_MOUNT="`echo ${MOUNT_INFO} | awk -F":" '{print $2}'`"
MOUNT_POINT="`echo ${MOUNT_INFO} | awk -F":" '{print $3}'`"
unmountOk=false

while [ ${unmountOk} == "false" ]; do
  (set -x; sudo umount "${MOUNT_POINT}" ; returnCode=${?})
  if [ "${returnCode}" == "0" ]; then
    unmountOk=true
    echo -e "\n  ** successful disk unmount ** \n"
  else
    echo -e "\n  ERROR: disk unmount failure\n"
    echo -e "\n  INFO: consider previously logged UMOUNT message\n"
    read -p "$(echo -e ${green}"  press Enter to try again... "${black})";
  fi
done

# gMODIFY
#sudo cryptsetup luksClose /dev/mapper/$VG_MOUNT
(set -x; sudo cryptsetup close /dev/mapper/${VG_MOUNT})
(set -x; sudo losetup --detach ${LO_MOUNT})
#// gMODIFY
#rm -f "disks/$DISK_NAME.mounted"
(set -x; rm -f "${DISK_DIR}/${DISK_NAME}.mounted")
(set -x; sudo rmdir "${MOUNT_POINT}")
(set -x; sudo -k)
