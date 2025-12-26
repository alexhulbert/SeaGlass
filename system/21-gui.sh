# systemd services for plasma
SystemdEnable --type user xdg-user-dirs /usr/lib/systemd/user/xdg-user-dirs.service
SystemdEnable --type user pipewire /usr/lib/systemd/user/pipewire.socket
SystemdEnable --type user wireplumber /usr/lib/systemd/user/wireplumber.service
SystemdEnable --type user pipewire-pulse /usr/lib/systemd/user/pipewire-pulse.socket
SystemdEnable bluez /usr/lib/systemd/system/bluetooth.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-dispatcher.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-wait-online.service
SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-powerd.service

# pamac
SystemdEnable libpamac-aur /usr/lib/systemd/system/pamac-cleancache.timer
CopyFileTo /pamac.conf /etc/pamac.conf

# remap laptop caps lock key to XF86Calculator for use in hyprland
CopyFileTo /caps.hwdb /etc/udev/hwdb.d/10-caps.hwdb

# spotify wayland compatibility
CopyFileTo /spotify.desktop /usr/share/applications/spotify.desktop

# hide notifications during screenshare
CopyFileTo /hyprland-portals.conf /usr/share/xdg-desktop-portal/hyprland-portals.conf

# firefox smart launcher (preloads, per-workspace windows)
CopyFileTo /firefox-smart /usr/bin/firefox
sed 's|/usr/lib/firefox/firefox|/usr/bin/firefox|g' /usr/share/applications/firefox.desktop >"$(CreateFile /usr/share/applications/firefox.desktop)"

# primenote theme
CreateLink /usr/lib/python3.13/site-packages/primenote/ui/palettes/wal.css $HOME/.cache/wal/primenote.css
# https://gitlab.com/william.belanger/primenote/-/issues/12
IgnorePath /usr/lib/python3.13/site-packages/primenote/backend/__init__.py
