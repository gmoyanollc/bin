#!/bin/bash
set -o xtrace
if [ ${#} -eq 3 ]; then
	yum_command=${1}
	package=${2}
	log_label=${3}
  log_dir=~/log-yum-logs
  if [ ! -d "$log_dir" ]; then
    mkdir ${log_dir}
  fi
	echo "****  yum ${yum_command} ${package}  ****" | tee -a ${log_dir}/${log_label}_yum.log
	date >> ${log_dir}/${log_label}_yum.log
	yum ${yum_command} "${package}" 2>&1 | tee -a ${log_dir}/${log_label}_yum.log
else
	echo "missing 3 arguments: yum_command package log_label"
fi
