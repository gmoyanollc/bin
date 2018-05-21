#!/usr/bin/bash
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

HELP="usage: ${0} source_dir source_name target_dir"
#system_mount_point="/run/media"
USER_MOUNT_POINT="/run/media"
#SYSTEM_MOUNT_POINT="/media"
GREEN="\033[32m"
BLACK="\033[0m"

if [ "${1}" == "" ]; then
  find ${HOME} -maxdepth 1 -type d 
  find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
  read -p "$(echo -e ${GREEN}"? source dir path: "${BLACK})" source_dir;
else
  if [ "${1}" == "--help" ]; then
    echo -e "\n  ${HELP}\n"
    exit 0
  else
    source_dir="${1}"
  fi
fi
if [ -d "${source_dir}" ]; then
  ls -1 "${source_dir}"
else
  echo "Error: ${source_dir} could not be found!"
  exit 1
fi
if [ "${2}" == "" ]; then
  read -p "$(echo -e ${GREEN}"? source name: "${BLACK})" source_name;
else
  source_name="${2}"
fi
if [ -f "${source_dir}/${source_name}" ]; then
  ls -1 "${source_dir}/${source_name}"
else
  echo "Error: ${source_dir}/${source_name} could not be found!"
  exit 1
fi

if [ "${3}" == "" ]; then
  MOUNT_POINT=${USER_MOUNT_POINT}/${USER}
  #set +x
  find ${USER_MOUNT_POINT}/${USER}/* -maxdepth 2 -type d
  #set -x
  read -p "$(echo -e ${GREEN}"? target dir: "${BLACK})" target_dir;
else
  target_dir="${3}"
fi
if [ -d "${target_dir}" ]; then
  eval "ls -1 '${target_dir}'"
else
  echo "Error: ${target_dir} could not be found!"
  exit 1
fi

date=$(date +%Y%m%d%H%M%S)
cp -v "${source_dir}/${source_name}" "${target_dir}/${source_name}-${date}" &
pid=$! # Process Id of the previous running command
echo -e "\ncopying...\n"
spin='-\|/'
i=0

while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf "\r${spin:$i:1}"
  sleep .1
done
echo -e "\ndone.\n"

