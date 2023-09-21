# /bin/bash

# usage: 

# 1. import this file
# 
# ```
#  source ./lib/get-last-device.sh
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
  local devices=$(ls /dev/${1}?)
  local lastDevice=${devices##*dev/}
  echo ${lastDevice}
}

