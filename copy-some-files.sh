# /usr/bash
# copy-some-files
FILE_NAME_FILTER=${1}
FILE_DAYS_FILTER=${2}
SOURCE_FOLDER=${3}
TARGET_FOLDER=${4}
echo FILE_NAME_FILTER: ${FILE_NAME_FILTER}
echo FILE_DAYS_FILTER: ${FILE_DAYS_FILTER}
echo SOURCE_FOLDER: ${SOURCE_FOLDER}
${SOURCE_FOLDER} -ctime ${FILE_DAYS_FILTER} -name "${FILE_NAME_FILTER}" -type f
echo TARGET_FOLDER: ${TARGET_FOLDER}
read "[INFO] press any key to continue"
find ${SOURCE_FOLDER} -ctime ${FILE_DAYS_FILTER} -name "${FILE_NAME_FILTER}" -type f | cpio -pdm ${TARGET_FOLDER}
echo [INFO] done.

