#!/usr/bin/env bash
rm ~/.cache/wallpaper
# wal -i $1
# wpg -s $1 --alpha 84
ln -s $1 ~/.cache/wallpaper
./move-colors-kde.sh Pywal
./apply-firefox-css.sh
sed "s/Opacity=1/Opacity=0.84/g" $HOME/.cache/wal/colors-konsole.colorscheme >$HOME/.local/share/konsole/colors-konsole.colorscheme
cp $HOME/.cache/wal/colors-albert.qss $HOME/.local/share/albert/widgetsboxmodel/themes/Pywal.qss
cp ~/.cache/wal/gtk2 ~/.gtkrc-2.0
cp ~/.cache/wal/gtk2 ~/.config/gtkrc-2.0
cp ~/.cache/wal/gtk2 ~/.config/gtkrc
cp ~/.cache/wal/gtk2 ~/.local/share/themes/FlatColor/gtk-2.0/gtkrc
cp ~/.cache/wal/gtk3.0 ~/.config/gtk-3.0/gtk.css
cp ~/.cache/wal/gtk3.0 ~/.local/share/themes/FlatColor/gtk-3.0/gtk.css
cp ~/.cache/wal/gtk3.20 ~/.local/share/themes/FlatColor/gtk-3.20/gtk.css
cp ~/.cache/wal/gtk3.20 ~/.config/gtk-4.0/gtk.css
feh --bg-fill $1
lookandfeeltool -a seaglass
systemctl --user restart picom

