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

USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
green="\033[32m"
black="\033[0m"
dirOk=false
#tryAgainDiskDir=false

while [ "${dirOk}" == "false" ]; do
  #if [ ! "${tryAgainDiskDir}" == "true" ]; then
  if [ "${1}" == "" ]; then
    find "${HOME}" -maxdepth 1 -type d 
    find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d 
    read -p "$(echo -e ${green}"? disk dir path: "${black})" disk_dir;
  else
    disk_dir="${1}"
  fi
  #fi
  #read -p "$(echo -e ${green}"? disk dir path: "${black})" disk_dir;
  if [ -d "${disk_dir}" ]; then
    dirOk=true
    ls -1 "${disk_dir}"
  else
    echo -e "\nERROR: directory ${disk_dir} could not be found!\n"
    read -p "  Press any key to try again.";
    #tryAgainDiskDir=true
    set -- "${@:1}" ""
  fi
done

fileOk=false

while [ "${fileOk}" == "false" ]; do
  read -p "$(echo -e ${green}"? disk file: "${black})" disk_name;
  if [ -e "${disk_dir}/${disk_name}" ]; then
    fileOk=true
    ls -1 "${disk_dir}/${disk_name}"
  else
    echo -e "\nERROR: file ${disk_dir}/${disk_name} could not be found!\n"
    #echo "${disk_dir}/${disk_name}"
    #ls -1 "${disk_dir}/${disk_name}"
  fi
done
  
set -x
MOUNT_POINT="${USER_MOUNT_POINT}/${USER}/${disk_name}"
set +x
dirOk=false
#tryAgainKeyDir=false

while [ "${dirOk}" == "false" ]; do
  #if [ ! "${tryAgainKeyDir}" == "true" ]; then
  find "${USER_MOUNT_POINT}/${USER}/"* -maxdepth 2 -type d
  #fi
  read -p "$(echo -e ${green}"? key dir (if key is not used, 'none'): "${black})" key_dir;
  if [ "${key_dir}" == "none" ]; then 
    no_key=0
    dirOk=true
  else
    if [ -d "${key_dir}" ]; then
      dirOk=true
      ls -1 "${key_dir}"
    else
      echo -e "\nERROR: directory ${key_dir} could not be found!\n"
      read -p "  Press any key to try again.";
      #exit 1
      #tryAgainKeyDir=true
    fi
  fi
done

  if [ ! "${no_key}" ]; then
    fileOk=false

    while [ "${fileOk}" == "false" ]; do
      read -p "$(echo -e ${green}"? PIN file: "${black})" pin_name;
      if [ -e "${key_dir}/${pin_name}" ]; then
        fileOk=true
        ls -1 "${key_dir}/${pin_name}"
        pin_file=${key_dir}/${pin_name}
        #// gCOMMENT neither of the following works for path containing space character
        #cypher="$(gpg -q -d ${pin_file})"
        #cypher=eval "gpg -q -d '${pin_file}'"
        # disable the ui prompt
        #cypher="$(GPG_AGENT_INFO='' gpg -q -d "${pin_file}")"; returnCode=${?}
      else
        echo -e "\nERROR: file ${key_dir}/${pin_name} could not be found!\n"
        #read -p "press any key to select another PIN file"
        #exit 1
      fi
    done

    cypherOk=false

    while [ "${cypherOk}" == "false" ]; do
    echo -e "\n[INFO] prompting for PIN file passphrase...\n"
      cypher="$(GPG_AGENT_INFO='' gpg -q -d "${pin_file}")"; returnCode=${?}
      if [ ${returnCode} == 0 ]; then
        cypherOk=true
        echo -e "\n[INFO] decrypting PIN file...success\n"
      fi
    done
    
    fileOk=false

    while [ "${fileOk}" == "false" ]; do
      read -p "$(echo -e ${green}"? key file: "${black})" key_name;
      if [ -e "${key_dir}/${key_name}" ]; then
        fileOk=true
        ls -1 "${key_dir}/${key_name}"
        key_file="${key_dir}/${key_name}"
      else
        echo -e "\nERROR: file ${key_dir}/${key_name} could not be found!\n"
        #read -p "press any key to select another key file"
        #exit 1
      fi
    done
    
  fi
#done

mount=true

while [ "${mount}" == "true" ]; do
  if [ -e "${disk_dir}/${disk_name}.mounted" ] || [ -d "${MOUNT_POINT}" ]; then
    if [ "$3" == "auto" ]; then
      exit 0
    else
      ls -1 "${MOUNT_POINT}"
      echo "Warning: Disk ${disk_name} may already be mounted!"
      read -p "$(echo -e ${green}"? ignore (y/n): "${black})" ignore;
      if [ "${ignore}" == "y" ]; then
        echo "ignored"
      else
        exit 1
      fi
    fi
  fi
  #if [ -d "$MOUNT_POINT" ]; then
  #    echo "Error: $MOUNT_POINT already exists!"
  #    exit 1
  #fi
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
  sudo losetup $LO_MOUNT "${disk_dir}/${disk_name}"
  returnCode=0
  decryptOk=false

  while [ "${decryptOk}" == "false" ]; do
    echo -e "\n[INFO] prompting for disk file passphrase...\n"
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
      echo -e "\n[INFO] decrypting disk file...success\n"
      sudo cryptsetup status $VG_MOUNT; (echo "return code: ${?}")
      sudo mount /dev/mapper/$VG_MOUNT "$MOUNT_POINT"; returnCode=${?}; (echo "return code: ${?}")
      if [ ${returnCode} == 0 ]; then
        echo -e "\n  ** successful disk mount ** \n"
        echo "$LO_MOUNT:$VG_MOUNT:$MOUNT_POINT" > "${disk_dir}/${disk_name}.mounted"
        sudo chown -R "$USER:$USER" "$MOUNT_POINT"
        sudo -k
      else
        echo -e "\n  ERROR: mount failure\n"
        exit
      fi
      echo -e "$(echo -e ${GREEN}"  ? ready to unmount disk: "${BLACK})\n" 
      
#      select unmount in "unmount" "quit"; do
      select unmount in "unmount"; do
        case ${unmount} in
          unmount ) sh unmount-disk.sh "${disk_dir}" "${disk_name}"; break;;
#          quit ) exit;;
        esac
      done
      
      echo -e "$(echo -e ${GREEN}"\n  ? re-mount disk: "${BLACK})\n" 
      echo -e "    NOTE: key file access is required"
      
      select remount in "remount" "backup" "quit"; do
        case ${remount} in
          remount ) mount=true ; break;;
          backup ) mount=false; sh backup-copy.sh "${disk_dir}" "${disk_name}"; break;;
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

# [George Moyano](https://onename.com/gmoyano)
# @github/gmoyanollc
# 2018-05-02 12:33:48 
