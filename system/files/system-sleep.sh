#!/bin/sh
case $1 in
	post)
		SOCKET_PATH=$(ls -trd /run/user/*/hypr/* | grep -v lock | tail -n 1)
		USER_ID=$(echo "$SOCKET_PATH" | cut -d'/' -f4)
		HYPRLAND_INSTANCE_SIGNATURE=$(echo "$SOCKET_PATH" | cut -d'/' -f6)
		sudo -u \#$USER_ID lidhandler
		;;
esac
