#!/usr/bin/env zsh

(
  sleep 1
  swww-daemon --no-cache &
  swww img $(readlink ~/.cache/wallpaper) --transition-step=255
) &

if grep open /proc/acpi/button/lid/LID0/state; then
  hyprctl keyword monitor eDP-1,highres,auto,auto
else
  MONITOR_COUNT=$(hyprctl monitors all -j | jq length)
  if [ "$MONITOR_COUNT" = "1" ]; then
    systemctl suspend
  else
    hyprctl keyword monitor eDP-1,disable
  fi
fi
