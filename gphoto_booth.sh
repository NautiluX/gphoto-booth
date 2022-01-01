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
  ret_val=1
  case $mode in
    'q') echo QUITTING ; exit ;;
    '[A') echo UP; ret_val=0 ;;
    '[B') echo DN; ret_val=0 ;;
    '[6') echo NEXT; ret_val=0 ;;
    '[5') echo PREV; ret_val=0 ;;
    '[D') echo LEFT; ret_val=0 ;;
    '[C') echo RIGHT; ret_val=0 ;;
    *) >&2 echo "ERR bad input: $mode" ;;
  esac
  echo $ret_val
  return $ret_val
}



cd ~/gphoto-booth/
pwd

killall gphoto2
gio mount -s gphoto2 || true
gphoto2 --set-config viewfinder=0
gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video7 > /dev/null 2>&1 &
mkdir -p pics
num="$(ls -al pics/booth_*.jpg | wc -l)"
if [[ $num == "" ]]; then
  num=0
fi

if ! pgrep obs; then
  export LIBGL_ALWAYS_SOFTWARE=1
  sleep 5s && obs > /dev/null 2>&1 &
  sleep 10s
fi

obs-cli --password asdf scenecollection set Booth

while true; do
  ((num++))
  obs-cli --password asdf label text smile "SMILE!"
  obs-cli --password asdf sceneitem hide Webcam smile
  obs-cli --password asdf scene switch Webcam
  {
    original_terminal_state="$(stty -g)"
    stty -icanon -echo min 0 time 0
    LC_ALL=C dd bs=1 > /dev/null 2>&1
    stty "$original_terminal_state"
  } < /dev/tty
   until wait-for-right; do
     echo "wrong key"
   done

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
  gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video7 > /dev/null 2>&1 &
  countdown
done
