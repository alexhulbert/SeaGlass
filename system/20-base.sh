# user files
cat >| "$(CreateFile '/etc/subuid')" <<< "${USER}:100000:65536"
cat >| "$(CreateFile '/etc/subgid')" <<< "${USER}:100000:65536"
cat <<EOF >| "$(CreateFile '/etc/sudoers')"
root ALL=(ALL:ALL) ALL
${USER} ALL=(ALL:ALL) NOPASSWD: ALL
@includedir /etc/sudoers.d
EOF

# windows dual boot system clock compat config
cat <<EOF >| "$(CreateFile '/etc/adjtime')"
0.0 0 0
0
LOCAL
EOF

CreateLink '/etc/os-release' '../usr/lib/os-release'

# base systemd services
SystemdEnable --name getty@tty1.service systemd /usr/lib/systemd/system/getty@.service
SystemdEnable systemd /usr/lib/systemd/system/remote-fs.target
SystemdEnable systemd /usr/lib/systemd/system/systemd-timesyncd.service
SystemdEnable --type user p11-kit /usr/lib/systemd/user/p11-kit-server.socket
SystemdEnable nix /usr/lib/systemd/system/nix-daemon.service
SystemdEnable tailscale /usr/lib/systemd/system/tailscaled.service
SystemdEnable openssh /usr/lib/systemd/system/sshd.service
SystemdEnable pcsclite /usr/lib/systemd/system/pcscd.socket

# for copilot key remapping
SystemdEnable interception-tools /usr/lib/systemd/system/udevmon.service
CopyFileTo /udevmon.yaml /etc/interception/udevmon.yaml
CopyFileTo /copilot.hwdb /etc/udev/hwdb.d/20-copilot.hwdb
CopyFileTo /copilot2ctrl /usr/local/bin/copilot2ctrl 755

# refresh display configuration on wake from suspend
CopyFileTo /system-sleep.sh /usr/lib/systemd/system-sleep/reload.sh 755

# locale and timezone config
cat >| "$(CreateFile '/etc/locale.gen')" <<< "en_US.UTF-8 UTF-8"
cat >| "$(CreateFile '/etc/locale.conf')" <<< "LANG=en_US.UTF-8"
cat >| "$(CreateFile '/etc/vconsole.conf')" <<< "KEYMAP=us"
CreateLink /etc/localtime /usr/share/zoneinfo/America/New_York

# terminal autologin
cat <<EOF >| "$(CreateFile '/etc/systemd/system/getty@tty1.service.d/autologin.conf')"
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin ${USER} --skip-login --nonewline --noissue %I \$TERM
EOF

# allow 1password unlock, etc. with fingerprint
CopyFileTo /kde-fingerprint.pam.conf /etc/pam.d/kde-fingerprint
CopyFileTo /polkit-1.pam.conf /etc/pam.d/polkit-1

# serial device permissions
cat <<EOF >| "$(CreateFile '/etc/udev/rules.d/40-serial.rules')"
KERNEL=="ttyUSB[0-9]*",MODE="0666"
KERNEL=="ttyACM[0-9]*",MODE="0666"
EOF

# disable lid close and power button suspend
CopyFileTo /logind.conf /etc/systemd/logind.conf

# bootloader/initramfs configuration
CopyFileTo /mkinitcpio.conf /etc/mkinitcpio.conf
CopyFileTo /grub.cfg /etc/default/grub
SystemdEnable grub-btrfs /usr/lib/systemd/system/grub-btrfsd.service

CopyFileTo /environment /etc/environment
