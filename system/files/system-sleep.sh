#!/bin/sh
SOCKET_PATH=$(ls -trd /run/user/*/hypr/* | grep -v lock | tail -n 1)
USER_ID=$(echo "$SOCKET_PATH" | cut -d'/' -f4)
SIG=$(echo "$SOCKET_PATH" | cut -d'/' -f6)
case $1 in
        post)
                sudo -u \#$USER_ID /bin/bash -c "\
                        export HYPRLAND_INSTANCE_SIGNATURE=$SIG WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/$USER_ID; \
			~/.local/bin/lidhandler"
                ;;
esac
