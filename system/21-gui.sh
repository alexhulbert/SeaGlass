# systemd services for plasma
SystemdEnable --type user xdg-user-dirs /usr/lib/systemd/user/xdg-user-dirs-update.service
SystemdEnable --type user pipewire-media-session /usr/lib/systemd/user/pipewire-media-session.service
SystemdEnable --type user pipewire /usr/lib/systemd/user/pipewire.socket
SystemdEnable --type user pulseaudio /usr/lib/systemd/user/pulseaudio.socket
SystemdEnable sddm /usr/lib/systemd/system/sddm.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-dispatcher.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-wait-online.service

# xsession
CopyFileTo xsession.desktop /usr/share/xsessions/plasma-i3.desktop
cat <<EOF >| "$(CreateFile '/etc/sddm.conf.d/autologin.conf')"
[Autologin]
User=${USER}
Session=plasma-i3
[Theme]
Current=Elegant
EOF
