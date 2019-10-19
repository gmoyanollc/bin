#! /usr/bin/bash
# convert-date-format.sh
read -p "Press any key to convert match '../../20..' to '..-..-20..n' in ${1}"
echo "[INFO] backup ${1}"
cp -v ${1} ${1}.bak
sed -i 's/^\(..\)\/\(..\)\/20\(..\)/\1-\2-20\3/' ${1}
echo "[INFO] done"
