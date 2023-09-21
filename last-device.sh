# /bin/bash

source ./lib/get-last-device.sh

result=$(getLastDevice ${1})
echo last-device: ${result}

