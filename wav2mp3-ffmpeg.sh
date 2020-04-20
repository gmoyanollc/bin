#/usr/bash
echo -x
# ffmpeg -i track01.wav -acodec mp3 -ab 64k track01.mp3
# https://video.stackexchange.com/questions/19860/batch-conversion-into-a-new-folder-with-ffmpeg
SOURCE_FOLDER=${1}/
ORIGIN_FOLDER=$(pwd)
echo SOURCE_FOLDER: ${SOURCE_FOLDER}
echo ORIGIN_FOLDER: ${ORIGIN_FOLDER}
ls ${SOURCE_FOLDER}
echo "[INFO] press any key to continue"
read
cd ${SOURCE_FOLDER}
# for i in *.wav; do ffmpeg -i "$i" "${i%.*}.mp3"; done
for i in *.wav; do ffmpeg -i "${i}" -acodec mp3 -ab 128k "${i%.*}.mp3"; done
echo SOURCE_FOLDER: ${SOURCE_FOLDER}
ls ${SOURCE_FOLDER}
cd ${ORIGIN_FOLDER}
echo [INFO] done.

