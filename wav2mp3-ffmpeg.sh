#/usr/bash
echo -x
# ffmpeg -i track01.wav -acodec mp3 -ab 64k track01.mp3
# https://video.stackexchange.com/questions/19860/batch-conversion-into-a-new-folder-with-ffmpeg
sourceFolder=${1}/
originFolder=$(pwd)
cd ${sourceFolder}
# for i in *.wav; do ffmpeg -i "$i" "${i%.*}.mp3"; done
for i in *.wav; do ffmpeg -i "${i}" -acodec mp3 -ab 128k "${i%.*}.mp3"; done
cd ${originFolder}

