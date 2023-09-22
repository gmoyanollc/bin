# /bin/bash

# usage: 

# 1. import this file
# 
# ```
#  source ~/bin/lib/get-last-device.sh
#
# ```
#
# 2. call and pass device argument for return value
#
# ```
#
#  result=$(getLastDevice tty)
#
# ```
#

function getLastDevice() {
  if [ -e "/dev/${1}0" ]; then
    local devices=$(ls /dev/${1}?)
    local lastDevice=${devices##*dev/}
    echo ${lastDevice}
  else
    echo ${1}0
  fi  
}

