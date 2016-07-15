#!/bin/bash
set -o xtrace
if [ ${#} -eq 3 ]; then
	yum_command=${1}
	package=${2}
	log_label=${3}
	echo "****  yum ${yum_command} ${package}  ****" | tee -a ~/install-log/${log_label}_yum.log
	date >> ~/install-log/${log_label}_yum.log
	yum ${yum_command} ${package} 2>&1 | tee -a ~/install-log/${log_label}_yum.log
	rpm -ql ${package} | tee -a ~/install-log/${log_label}_yum.log
else
	echo "missing 3 arguments: yum_command package log_label"
fi
