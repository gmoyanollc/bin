# /usr/bash
# copy-some-files
FILE_NAME_FILTER=${1}
#FILE_DAYS_FILTER=${2}
SOURCE_FOLDER=${2}
TARGET_FOLDER=${3}
echo FILE_NAME_FILTER: ${FILE_NAME_FILTER}
#echo FILE_DAYS_FILTER: ${FILE_DAYS_FILTER}
echo SOURCE_FOLDER: ${SOURCE_FOLDER}
#find ${SOURCE_FOLDER} -ctime ${FILE_DAYS_FILTER} -name "${FILE_NAME_FILTER}" -type f
echo TARGET_FOLDER: ${TARGET_FOLDER}
#find ${SOURCE_FOLDER} -ctime ${FILE_DAYS_FILTER} -name "${FILE_NAME_FILTER}" -type f | cpio -dpmv ${TARGET_FOLDER}
rsync -avmn --include "${FILE_NAME_FILTER}" --exclude "*.*" ${SOURCE_FOLDER} ${TARGET_FOLDER}
echo "[INFO] press any key to continue"
read
rsync -avm --include "${FILE_NAME_FILTER}" --exclude "*.*" ${SOURCE_FOLDER} ${TARGET_FOLDER}
echo [INFO] done.

