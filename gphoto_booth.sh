#!/bin/bash

function countdown {
  obs-cli --password asdf label text countdown 5
  sleep 1s
  obs-cli --password asdf label text countdown 4
  sleep 1s
  obs-cli --password asdf label text countdown 3
  sleep 1s
  obs-cli --password asdf label text countdown 2
  sleep 1s
  obs-cli --password asdf label text countdown 1
  sleep 1s
}

function wait-for-right {
  escape_char=$(printf "\u1b")
  read -rsn1 mode # get 1 character
  if [[ $mode == $escape_char ]]; then
    read -rsn2 mode # read 2 more chars
  fi
  case $mode in
    'q') echo QUITTING ; exit ;;
    '[A') echo UP ;;
    '[B') echo DN ;;
    '[D') echo LEFT ;;
    '[C') echo RIGHT ;;
    *) >&2 echo 'ERR bad input'; return ;;
  esac
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! pgrep obs; then
  sleep 5s && obs &
fi

cd "$DIR"

killall gphoto2
gio mount -s gphoto2 || true
gphoto2 --set-config viewfinder=0
gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 12 -f v4l2 /dev/video7 > /dev/null 2>&1 &
mkdir -p pics
num="$(ls -al pics/booth_*.jpg | wc -l)"
if [[ $num == "" ]]; then
  num=0
fi
while true; do
  ((num++))
  obs-cli --password asdf label text smile "SMILE!"
  obs-cli --password asdf sceneitem hide Webcam smile
  obs-cli --password asdf scene switch Webcam

  wait-for-right

  obs-cli --password asdf sceneitem show Webcam smile
  killall gphoto2
  while true; do
    if gphoto2 --set-config viewfinder=0; then
      break
    fi
  done
  #gphoto2 --capture-preview --filename=$FILENAME --force-overwrite
  FILENAME="$(printf "pics/booth_%04d.jpg" "$num")"
  gphoto2 --capture-image-and-download --filename=$FILENAME --force-overwrite

  if [[ $? -ne 0 ]]; then
    obs-cli --password asdf label text smile "FAILED! Please try again."
    obs-cli --password asdf sceneitem show Webcam countdown
    countdown
    obs-cli --password asdf sceneitem hide Webcam countdown
    continue
  fi
  cp $FILENAME /tmp/booth-preview.jpg
  obs-cli --password asdf scene switch image
  gphoto2 --set-config viewfinder=0
  gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 12 -f v4l2 /dev/video7 > /dev/null 2>&1 &
  countdown
done
