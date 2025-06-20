#!/usr/bin/bash
HELP="\n  usage: enter ${0} [output_filename].png\
  \
  \n\n  When prompted type, paste data for qr-code.\n";

output_filename=${1};
if [[ -z "${output_filename}" ]]; then
  echo -e ${HELP};
  exit;
fi  
qr_code_data=${2};
if [[ -z "${qr_code_data}" ]]; then
 echo -e "\n Type or paste data. Ctrl-D to end input.\n";
 qr_code_data=$(cat);
fi
qrencode -o ${output_filename} <<< ${qr_code_data};
echo -e "\n done.  qr-code created in $(pwd)/${output_filename}";
gio open $(pwd)/${output_filename};
echo -e "\n file opened by image viewer.\n"
