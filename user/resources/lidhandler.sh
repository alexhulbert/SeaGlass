#!/usr/bin/env zsh

if grep open /proc/acpi/button/lid/LID0/state; then
  hyprctl keyword monitor eDP-1,preferred,auto,auto
else
  MONITOR_COUNT=$(hyprctl monitors all -j | jq length)
  if [ "$MONITOR_COUNT" = "1" ]; then
    systemctl suspend
  else
    hyprctl keyword monitor eDP-1,disable
  fi
fi
