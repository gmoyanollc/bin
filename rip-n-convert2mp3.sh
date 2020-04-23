# /usr/bin/bash
echo "[INFO] ready to rip to current directory..."
echo "[INFO] $(pwd)" 
sudo cdparanoia -B
echo -ne "[INFO] done...ready to eject...\007"
sudo eject
echo -ne "[INFO] convert wav to mp3...\007"
bash ~/bin/wav2mp3-ffmpeg.sh .
echo -ne "[INFO] done.\007"
