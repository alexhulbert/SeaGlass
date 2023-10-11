# user files
cat >| "$(CreateFile '/etc/subuid')" <<< "${USER}:100000:65536"
cat >| "$(CreateFile '/etc/subgid')" <<< "${USER}:100000:65536"
cat <<EOF >| "$(CreateFile '/etc/sudoers')"
root ALL=(ALL:ALL) ALL
${USER} ALL=(ALL:ALL) NOPASSWD: ALL
@includedir /etc/sudoers.d
EOF

CreateLink '/etc/os-release' '../usr/lib/os-release'

# base systemd services
SystemdEnable --name getty@tty1.service systemd /usr/lib/systemd/system/getty@.service
SystemdEnable systemd /usr/lib/systemd/system/remote-fs.target
SystemdEnable --type user p11-kit /usr/lib/systemd/user/p11-kit-server.socket
SystemdEnable nix /usr/lib/systemd/system/nix-daemon.service

# locale and timezone config
cat >| "$(CreateFile '/etc/locale.gen')" <<< "en_US.UTF-8 UTF-8"
cat >| "$(CreateFile '/etc/locale.conf')" <<< "LANG=en_US.UTF-8"
cat >| "$(CreateFile '/etc/vconsole.conf')" <<< "KEYMAP=us"
CreateLink /etc/localtime /usr/share/zoneinfo/America/New_York

# disable caps key for i3 workspace back-and-forth
CopyFileTo /xorg-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf

# bootloader configuration
CopyFileTo /grub.cfg /etc/default/grub
SystemdEnable grub-btrfs /usr/lib/systemd/system/grub-btrfsd.service

CopyFileTo /environment /etc/environment
