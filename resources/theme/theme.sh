#!/usr/bin/env fish
wal -i ~alex/Pictures/1.jpg
./kde.sh
sed "s/Opacity=1/Opacity=0.75/g" $HOME/.cache/wal/colors-konsole.colorscheme > $HOME/.local/share/konsole/colors-konsole.colorscheme
