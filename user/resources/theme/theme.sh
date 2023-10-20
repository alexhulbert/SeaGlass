#!/usr/bin/env bash
(
if [ -e "$1.scheme" ]; then
  echo test
  # pass
else
  rm ~/.cache/wallpaper
  ln -s $1 ~/.cache/wallpaper
  sudo cp $1 /usr/share/sddm/themes/Elegant/background.jpg
  feh --bg-fill $1
  wal --backend haishoku -i $1
fi
source ~/.cache/wal/colors.sh
kde-material-you-colors -col $background -ccl "$color1 $color2 $color3 $color4 $color5 $color6 $color7" -wal -kp Pywal -ko 84 --on-change-hook "kde-material-you-colors --stop"
if [ ! -d "~/.local/share/themes/FlatColor" ]; then
  wpg-install.sh -gi
fi
wpg -i ~/.cache/wallpaper ~/.cache/wal/colors.json
wpg -s ~/.cache/wallpaper
cp $HOME/.cache/wal/colors-albert.qss $HOME/.local/share/albert/widgetsboxmodel/themes/Pywal.qss
albert restart
sleep 1
sed -i 's/BackgroundNormal=#/BackgroundNormal=#D6/g' ~/.local/share/color-schemes/MaterialYouDark.colors
lookandfeeltool -a seaglass
systemctl --user restart picom
) &
