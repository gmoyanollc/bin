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
# // mount-disk.sh mounts an asynchronously encrypted virtual partition file.  
#
# // mount-disk.sh is designed to implement two-factor authentication with the  
# // key file stored on an external resource such as a USB drive.
#
# // mount-disk.sh works in conjuction with unmount-disk.sh and create-disk.sh.
#
# // Original source: https://patrick.uiterwijk.org/blog/2013/2/25/gpg-encrypted-loopback-disks
# //
# // Copyright (2016-2017), [George Moyano](https://onename.com/gmoyano)
# // All rights reserved.
# //
# // Source code lines and blocks preceded by the characters "// g" are contributions 
# // by George Moyano.  Such contributions are copyrighted source held and licensed by 
# // George Moyano under the aforementioned terms.
# }

# Configuration
#// gINSERT {
USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
green="\033[32m"
black="\033[0m"
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
    set -- "${@:1}" ""
  fi
done

fileOk=false

while [ ${fileOk} == "false" ]; do
  read -p "$(echo -e ${green}"? disk file: "${black})" disk_name;
  if [ -f "${disk_dir}/${disk_name}" ]; then
    fileOk=true
    ls -1 "${disk_dir}/${disk_name}"
  else
    echo -e "\nERROR: file ${disk_dir}/${disk_name} could not be found!\n"
    #read -p "press any key to select another disk file"
    #exit 1
  fi
done
  
set -x
#}
#// gCOMMENT
#disk_name=$1
#// gMODIFY
#MOUNT_POINT=$2
MOUNT_POINT=${USER_MOUNT_POINT}/${USER}/${disk_name}
#// gINSERT {
set +x
dirOk=false

while [ ${dirOk} == "false" ]; do
  find ${USER_MOUNT_POINT}/${USER}/* -maxdepth 2 -type d
  read -p "$(echo -e ${green}"? key dir ('n/a' for no key): "${black})" key_dir;
  if [ "${key_dir}" == "n/a" ]; then 
    no_key=0
  else
    if [ -d "${key_dir}" ]; then
      dirOk=true
      eval "ls -1 '${key_dir}'"
    else
      echo -e "\nERROR: directory ${key_dir} could not be found!\n"
      #read -p "press any key to select another key directory"
      #exit 1
    fi
    fileOk=false

    while [ ${fileOk} == "false" ]; do
      read -p "$(echo -e ${green}"? key file: "${black})" key_name;
      if [ -f "${key_dir}/${key_name}" ]; then
        fileOk=true
        ls -1 "${key_dir}/${key_name}"
        key_file=${key_dir}/${key_name}
      else
        echo -e "\nERROR: file ${key_dir}/${key_name} could not be found!\n"
        #read -p "press any key to select another key file"
        #exit 1
      fi
    done

    fileOk=false
    while [ ${fileOk} == "false" ]; do
      read -p "$(echo -e ${green}"? pin file: "${black})" pin_name;
      if [ -f "${key_dir}/${pin_name}" ]; then
        fileOk=true
        ls -1 "${key_dir}/${pin_name}"
        pin_file=${key_dir}/${pin_name}
        #// gCOMMENT neither of the following works for path containing space character
        #cypher="$(gpg -q -d ${pin_file})"
        #cypher=eval "gpg -q -d '${pin_file}'"
        # disable the ui prompt
        cypher="$(GPG_AGENT_INFO='' gpg -q -d "${pin_file}")"
      else
        echo -e "\nERROR: file ${key_dir}/${pin_name} could not be found!\n"
        #read -p "press any key to select another pin file"
        #exit 1
      fi
    done
    
  fi
done

mount=true

while [ ${mount} == "true" ]; do
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
  if [ -f "${disk_dir}/${disk_name}.mounted" ];
  then
    if [ "$3" == "auto" ];
    then
      exit 0
    else
      #// gMODIFY
      #echo "Error: Disk $disk_name is already mounted!"
      echo "Warning: Disk ${disk_name} may already be mounted!"
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
  #// gCOMMENT left single quotes aren't working as expected in bash, in sh, they execute
  LO_MOUNT=`losetup -f`
  VG_MOUNT=`date +%s | sha1sum | head -c 8`
  #// gMODIFY
  #sudo losetup $LO_MOUNT "disks/$disk_name.disk"
  sudo losetup $LO_MOUNT "${disk_dir}/${disk_name}"
  #// gINSERT
  decryptOk=false

  while [ ${decryptOk} == "false" ]; do
    echo -e "\ndecrypting...\n"
    #// gMODIFY
    #// gCOMMENT asymmetric encryption
    #gpg --no-default-keyring --secret-keyring keyrings/secret.gpg --keyring keyrings/public.gpg --trustdb-name keyrings/trustdb.gpg --decrypt "disks/$disk_name.key.gpg" | sudo cryptsetup luksOpen $LO_MOUNT $VG_MOUNT -d -
    if [ ${no_key} ]; then 
      #// gCOMMENT symmetric encryption
      #sudo cryptsetup create $VG_MOUNT $LO_MOUNT
      sudo cryptsetup --key-file - create $VG_MOUNT $LO_MOUNT; returnCode=${?}
    else
      #// gCOMMENT return code 32 is thrown when the wrong key file is applied to decryption
      eval "gpg -q -d '${key_file}'" | sudo cryptsetup ${cypher} --key-file - create $VG_MOUNT $LO_MOUNT; returnCode=${?}
    fi
    if [ ${returnCode} == 0 ]; then 
      decryptOk=true
      #// gINSERT
      sudo cryptsetup status $VG_MOUNT; (echo "return code: ${?}")
      sudo mount /dev/mapper/$VG_MOUNT "$MOUNT_POINT"; returnCode=${?}; (echo "return code: ${?}")
      #// gINSERT {
      if [ ${returnCode} == 0 ]; then
        echo -e "\n  ** successful disk mount ** \n"
        #// gINSERT }
        #// gMODIFY
        #echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"disks/$disk_name.mounted"
        echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" >"${disk_dir}/${disk_name}.mounted"
        #// gINSERT
        sudo chown -R "$USER:$USER" "$MOUNT_POINT"
        sudo -k
      else
        echo -e "\n  ERROR: mount failure\n"
        exit
      fi
      echo -e "$(echo -e ${GREEN}"  ? ready to unmount disk: "${BLACK})\n" 
      
      select unmount in "yes" "quit"; do
        case ${unmount} in
          yes ) sh unmount-disk.sh ${disk_dir} ${disk_name}; break;;
          quit ) exit;;
        esac
      done
      
      echo -e "$(echo -e ${GREEN}"\n  ? re-mount disk: "${BLACK})\n" 
      echo -e "    NOTE: key file access is required"
      
      select remount in "yes" "quit"; do
        case ${unmount} in
          yes ) mount=true ; break;;
          quit ) mount=false ; break;;
        esac
      done
      
    else
      zenity --question --text="decryption attempt failed, try again?"; returnCode=${?}
      if [ ${returnCode} == 1 ]; then
        exit 1
      fi
    fi
  done
  
done # mount

