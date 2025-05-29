#!/usr/bin/env bash

if [ -z "$1" ]; then
	wallpaper=$(find ~/.config/wallpaper/ -type f | shuf -n 1)
else
	wallpaper=$1
fi

if [ -e "$wallpaper.scheme" ]; then
	echo test
	# pass
else
	rm ~/.cache/wallpaper
	ln -s "$wallpaper" ~/.cache/wallpaper
	echo "$wallpaper" >~/.cache/wallpaper-path
	if ! pgrep -x "swww-daemon" >/dev/null; then
		export SWWW_TRANSITION_STEP=255
	fi
	swww-daemon --no-cache &
	swww img "$wallpaper"
fi

kde-material-you-colors --file ~/.cache/wallpaper-path --iconsdark Papirus-Colors-Dark --iconslight Papirus-Colors --chroma-multiplier 1.25 -wal -ko 84 --scheme-variant 6 --on-change-hook "kde-material-you-colors --stop"
source ~/.cache/wal/colors.sh
sed -i "/\[Colors:Window]/,+2 s/=#....../=$background/g" ~/.local/share/color-schemes/MaterialYouDark.colors
sed -Ei '/\[Colors:(Header|Tooltip|Complementary)\]/,+2 s/=#/=#D4/g' ~/.local/share/color-schemes/MaterialYouDark.colors
sed -i '/\[Colors:View\]/,+2 s/=#/=#44/g' ~/.local/share/color-schemes/MaterialYouDark.colors

lookandfeeltool -a "$HOME/.local/share/plasma/look-and-feel/sealass"
plasma-apply-colorscheme MaterialYouDark2
plasma-apply-colorscheme MaterialYouDark

# change breeze gtk background to match qt
sleep 0.5
gtkBkg=$(grep 'theme_bg_color_breeze' ~/.config/gtk-3.0/colors.css | cut -d' ' -f3 | cut -c 1-7)
sed -i "s/$gtkBkg/$background/g" ~/.config/gtk-3.0/colors.css
sed -i "s/$gtkBkg/$background/g" ~/.config/gtk-4.0/colors.css

# add selection colors
for file in "$HOME/.config/gtk-3.0/colors.css" "$HOME/.config/gtk-4.0/colors.css"; do
	mkdir -p "$(dirname "$file")"
	grep -q "@define-color selected_bg_color" "$file" 2>/dev/null || echo "
@define-color selected_bg_color @theme_selected_bg_color_breeze;
@define-color selected_fg_color @theme_selected_fg_color_breeze;" >>"$file"
done

pywalfox update

systemctl --user restart ulauncher swaync swayosd ags waybar &
seaglass-spicetify
