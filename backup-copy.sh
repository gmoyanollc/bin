#!/usr/bin/bash
set -x
# Copyright (2016), [George Moyano](https://onename.com/gmoyano)
#
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

HELP="usage: ${0} source target_dir"
USER_MOUNT_POINT="/run/media"
#SYSTEM_MOUNT_POINT="/media"
GREEN="\033[32m"
BLACK="\033[0m"

if [ "${1}" == "" ]; then
  find ${HOME} -maxdepth 1 -type d 
  find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
  read -p "$(echo -e ${GREEN}"? source dir path: "${BLACK})" source_dir;
  if [ -d "${source_dir}" ]; then
    ls -1 "${source_dir}"
    read -p "$(echo -e ${GREEN}"? source name: "${BLACK})" source_name;
    source="${source_dir}/${source_name}"
    if [ -f "${source}" ]; then
      ls -1 "${source}"
    else
      if [ -d "${source}" ]; then
        echo "[INFO] directory selected"
        isDir=true
      else
        read -p "[ERROR] ${source} could not be found!"
        exit 1
      fi
    fi  
  else
    read -p "[ERROR] ${source_dir} could not be found!"
    exit 1
  fi
else
  if [ "${1}" == "--help" ]; then
    echo -e "\n  ${HELP}\n"
    exit 0
  else
    source="${1}"
  fi
fi
echo "source: ${source}"
if [ "${2}" == "" ]; then
  MOUNT_POINT=${USER_MOUNT_POINT}/${USER}
  #set +x
  find ${HOME} -maxdepth 1 -type d
  find ${USER_MOUNT_POINT}/${USER}/* -maxdepth 2 -type d
  #set -x
  read -p "$(echo -e ${GREEN}"? target dir: "${BLACK})" target_dir;
else
  target_dir="${2}"
fi
if [ -d "${target_dir}" ]; then
  eval "ls -1 '${target_dir}'"
else
  read -p "[ERROR] ${target_dir} could not be found!"
  exit 1
fi

date=$(date +%Y%m%d%H%M%S)
target_name="${target_dir}/$(basename "${source}")-${date}"
echo -e "\n[INFO] copying...\n"
if [ "${isDir}" == "true" ]; then
#  rsync -a --progress "${source}/." "${target_name}"
  cp -avr "${source}/" "${target_name}"
else
#  rsync -a --progress "${source}" "${target_name}"
  cp -av "${source}" "${target_name}"
fi
echo -e "\n[INFO] done: ${target_name}\n"
#read -p ':'

