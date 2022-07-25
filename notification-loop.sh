# /usr/bin/bash
if [[ -z ${1} ]];
then
  echo -e "  [warning] only timestamp will display"
  echo -e "  optional command may be executed as an argument"
  echo -e "\n  for example:"
  echo -e "\n    bash ./notification-loop.sh 'espeak battery_is_low_at_20%'\n"
fi
timeStamp=$(date)
for (( c=1; c<=1; c )); do 
  echo -ne [INFO] done: ${timeStamp}  
  $(${1})
  echo
  sleep 1 
done

