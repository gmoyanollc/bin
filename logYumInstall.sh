#!/bin/bash
set -x

date & yum -y install $1 2>&1 | tee -a ~/log/$1.log
rpm -ql $1 | tee -a ~/log/$1.log
