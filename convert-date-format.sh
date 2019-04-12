#! /usr/bin/bash
read -p "Press any key to convert match '../../20..' to '..-..-20..n' in ${1}"
cp -v ${1} ${1}.bak
sed -i 's/^\(..\)\/\(..\)\/20\(..\)/\1-\2-20\3/p' ${1}

