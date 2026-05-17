wordCount="${1}"
[ "${wordCount}" == "" ] && wordCount="5"
readarray -t randomWords < <(shuf -n ${wordCount} /usr/share/dict/words | xargs -d "\n" echo );
echo -e "\n${randomWords[@]}" | tr ' ' '-'

