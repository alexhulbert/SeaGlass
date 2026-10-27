cat >"$(CreateFile /etc/plymouth/plymouthd.conf)" <<'EOF'
[Daemon]
Theme=seaglass
UseSimpledrm=1
EOF

# Don't get rid of plymouth until just before Hyprland starts
for unit in plymouth-quit plymouth-quit-wait; do
    cat >"$(CreateFile /etc/systemd/system/$unit.service.d/handoff.conf)" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/true
EOF
done
cat >"$(CreateFile /etc/systemd/user/wayland-wm@hyprland.desktop.service.d/plymouth.conf)" <<'EOF'
[Service]
ExecStartPre=-/usr/bin/sudo -n /usr/bin/plymouth deactivate
ExecStartPost=-/usr/bin/sudo -n /usr/bin/plymouth quit --retain-splash
ExecStopPost=-/usr/bin/sudo -n /usr/bin/plymouth quit
EOF

SystemdEnable --type user xdg-user-dirs /usr/lib/systemd/user/xdg-user-dirs.service
SystemdEnable --type user pipewire /usr/lib/systemd/user/pipewire.socket
SystemdEnable --type user wireplumber /usr/lib/systemd/user/wireplumber.service
SystemdEnable --type user pipewire-pulse /usr/lib/systemd/user/pipewire-pulse.socket
SystemdEnable bluez /usr/lib/systemd/system/bluetooth.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-dispatcher.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager.service
SystemdEnable networkmanager /usr/lib/systemd/system/NetworkManager-wait-online.service

cat >"$(CreateFile /etc/NetworkManager/dispatcher.d/20-tzupdate 755)" <<'EOF'
#!/bin/sh
case "$2" in
    up) exec /usr/bin/tzupdate --timeout 10 ;;
    connectivity-change)
        [ "$CONNECTIVITY_STATE" != FULL ] || exec /usr/bin/tzupdate --timeout 10
        ;;
esac
EOF

extensions=("$cfg_root/modules/home/programs/firefox/extensions.json")
[[ ! -f "$cfg_root/users/$cfg_user/config/firefox/extensions.json" ]] || extensions+=("$cfg_root/users/$cfg_user/config/firefox/extensions.json")
jq -s 'add | {policies: {ExtensionSettings: map_values({installation_mode: "normal_installed", install_url: .})}}' \
    "${extensions[@]}" >"$(CreateFile /etc/firefox/policies/policies.json)"

CreateLink /usr/lib/qt/plugins/platformthemes/libqt5engine-plugin.so /usr/lib/qt5/plugins/platformthemes/libqt5engine-plugin.so
CreateLink /usr/lib/qt/plugins/styles/libqt5engine-style.so /usr/lib/qt5/plugins/styles/libqt5engine-style.so
