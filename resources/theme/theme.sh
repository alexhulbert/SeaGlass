#!/usr/bin/env bash
rm ~/.cache/wallpaper
ln -s $1 ~/.cache/wallpaper
wal -i $1
./move-colors-kde.sh Pywal
./apply-firefox-css.sh
wpg -s $1 --alpha 0.84
./intellijPywal/intellijPywalGen.sh ~/.config/JetBrains/$(ls ~/.config/JetBrains | head)
# wpg-install.sh -ig
sed "s/Opacity=1/Opacity=0.84/g" $HOME/.cache/wal/colors-konsole.colorscheme > $HOME/.local/share/konsole/colors-konsole.colorscheme
lookandfeeltool -a nixos
