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
# "create a (pseudo) random keyfile"
# "keyfile will be encrypted with GPG (using a typed-in passphrase)"
# enable "dual-factor security - both the (encrypted) keyfile, 
#   and your passphrase (to decrypt it) will be required to access..."

USER_MOUNT_POINT="/run/media"
SYSTEM_MOUNT_POINT="/media"
green="\033[32m"
black="\033[0m"
dirOk=false
#tryAgainKeyDir=false

while [ "${dirOk}" == "false" ]; do
  #if [ ! "${tryAgainKeyDir}" == "true" ]; then
    if [ "${1}" == "" ]; then
      find "${HOME}" -maxdepth 1 -type d 
      find "${USER_MOUNT_POINT}/${USER}" "${SYSTEM_MOUNT_POINT}" -maxdepth 2 -type d
      read -p "$(echo -e ${green}"? new key dir path: "${black})" key_dir;
    else
      key_dir="${1}"
    fi
  #fi
  if [ -d "${key_dir}" ]; then
    dirOk=true
    ls -1 "${key_dir}"
  else
      echo -e "\n  [ERROR] Directory ${key_dir} could not be found!\n"
      read -p "  Press any key to try again.";
      #tryAgainKeyDir=true
      set -- "${@:1}" ""
    #exit 1
  fi
done

read -p "$(echo -e ${green}"? new key name (exclude '.gpg' suffix): "${black})" key_name;
set -x
export GPG_TTY=$(tty) 
key_file="${key_dir}/${key_name}.gpg"
# "the cryptsetup system can support keyfiles up to and including 8192KiB"
# "in practice, due to a off-by-one bug, it supports only keyfiles strictly
#   less than 8MiB. We therefore create a keyfile of length (1024 * 8192) - 1 = 8388607 bytes."
dd if=/dev/urandom bs=8388607 count=1 | gpg --symmetric --cipher-algo AES256 --output "${key_file}"
set +x
if [ -f "${key_file}" ];
then
  ls -1 "${key_file}"
  #gpg -q -d "${key_file}"
else
  echo "Error: ${key_file} could not be found!"
  exit 1
fi

