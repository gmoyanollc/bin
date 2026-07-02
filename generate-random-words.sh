wordCount="${1}"
[ "${wordCount}" == "" ] && wordCount="5"
echo -e "\n{"
readarray -t randomWords < <(shuf -n ${wordCount} /usr/share/dict/words | xargs -d "\n" echo );
printf " \"words\": "
echo -e "\"${randomWords[@]}\"," | tr ' ' '-'
printf " \"generated\": \""; printf '%(%Y%m%d%H%M%S)T' -1; echo "\""
echo -e "}\n"
