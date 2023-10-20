#!/usr/bin/env bash
(
if [ -e "$1.scheme" ]; then
  echo test
  # pass
else
  rm ~/.cache/wallpaper
  ln -s $1 ~/.cache/wallpaper
  feh --bg-fill $1
  kde-material-you-colors -wal -kp Pywal -ko 84 --on-change-hook "kde-material-you-colors --stop"
  if [ ! -d "~/.local/share/themes/FlatColor" ]; then
    wpg-install.sh -g
  fi
  wpg -i ~/.cache/wallpaper ~/.cache/wal/colors.json
  wpg -s ~/.cache/wallpaper
fi
cp $HOME/.cache/wal/colors-albert.qss $HOME/.local/share/albert/widgetsboxmodel/themes/Pywal.qss
albert restart
sleep 1
sed -i 's/BackgroundNormal=#/BackgroundNormal=#D6/g' ~/.local/share/color-schemes/MaterialYouDark.colors
lookandfeeltool -a seaglass
systemctl --user restart picom
) &
