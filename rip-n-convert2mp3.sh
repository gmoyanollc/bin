# /usr/bin/bash
echo "[INFO] ready to rip to current directory..."
echo "[INFO] $(pwd)" 
sudo cdparanoia -B
echo "[INFO] done...ready to eject..."
sudo eject
echo "[INFO] convert wav to mp3..."
bash ~/bin/wav2mp3-ffmpeg.sh .
echo "[INFO] done."
