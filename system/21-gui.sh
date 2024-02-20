# systemd services for plasma
SystemdEnable --type user xdg-user-dirs /usr/lib/systemd/user/xdg-user-dirs-update.service
SystemdEnable --type user pipewire /usr/lib/systemd/user/pipewire.socket
SystemdEnable --type user wireplumber /usr/lib/systemd/user/wireplumber.service
SystemdEnable --type user pulseaudio /usr/lib/systemd/user/pulseaudio.socket
SystemdEnable bluez /usr/lib/systemd/system/bluetooth.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-dispatcher.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-wait-online.service

# pamac
SystemdEnable libpamac-aur /usr/lib/systemd/system/pamac-cleancache.timer
CopyFileTo /pamac.conf /etc/pamac.conf

# patched to fix transparency issues
CopyFileTo /plasmawindowed /usr/bin/plasmawindowed

# remap laptop caps lock key to XF86Calculator for use in hyprland
CopyFileTo /caps.hwdb /etc/udev/hwdb.d/10-caps.hwdb