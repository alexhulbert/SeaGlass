#!/bin/bash
sleep 0.2
output=$(hyprctl clients -j)
todoist_ws=$(jq -r 'map(select(.class == "chrome-todoist.com__-Default"))[0].workspace.name // ""' <<<"$output")
beeper_ws=$(jq -r 'map(select(.class == "chrome-chat.beeper.com__-Default"))[0].workspace.name // ""' <<<"$output")

if [[ -n "$todoist_ws" && ! "$todoist_ws" =~ scratch ]] ||
	[[ -n "$beeper_ws" && ! "$beeper_ws" =~ scratch ]]; then
	if [ "$(hyprctl monitors -j | jq '.[0].reserved[1]')" -gt 4 ]; then
		killall -SIGUSR1 waybar
	fi
else
	# Both windows are hidden in scratchpads, show waybar
	if [ "$(hyprctl monitors -j | jq '.[0].reserved[1]')" -lt 5 ]; then
		killall -SIGUSR1 waybar
	fi
fi
