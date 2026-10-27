cat >|"$(CreateFile '/etc/subuid')" <<<"${cfg_user}:100000:65536"
cat >|"$(CreateFile '/etc/subgid')" <<<"${cfg_user}:100000:65536"
cat <<EOF >|"$(CreateFile '/etc/sudoers')"
root ALL=(ALL:ALL) ALL
${cfg_user} ALL=(ALL:ALL) NOPASSWD: ALL
@includedir /etc/sudoers.d
EOF

# windows dual boot system clock compat config
cat <<EOF >|"$(CreateFile '/etc/adjtime')"
0.0 0 0
0
LOCAL
EOF

CreateLink '/etc/os-release' '../usr/lib/os-release'

SystemdEnable --name getty@tty1.service systemd /usr/lib/systemd/system/getty@.service
SystemdEnable systemd /usr/lib/systemd/system/remote-fs.target
SystemdEnable systemd /usr/lib/systemd/system/systemd-timesyncd.service
SystemdEnable --type user p11-kit /usr/lib/systemd/user/p11-kit-server.socket
SystemdEnable nix /usr/lib/systemd/system/nix-daemon.service
SystemdEnable tailscale /usr/lib/systemd/system/tailscaled.service
SystemdEnable openssh /usr/lib/systemd/system/sshd.service
SystemdEnable pcsclite /usr/lib/systemd/system/pcscd.socket

cat >|"$(CreateFile '/etc/locale.gen')" <<<"en_US.UTF-8 UTF-8"
cat >|"$(CreateFile '/etc/locale.conf')" <<<"LANG=en_US.UTF-8"
cat >|"$(CreateFile '/etc/vconsole.conf')" <<<"KEYMAP=us"

# Login directly since agetty closes Plymouth early
cat <<EOF >|"$(CreateFile '/etc/systemd/system/getty@tty1.service.d/autologin.conf')"
[Service]
Type=simple
Environment=UWSM_SILENT_START=2
TTYReset=no
TTYVHangup=no
TTYVTDisallocate=no
ExecStart=
ExecStart=-/usr/bin/login -p -f ${cfg_user}
EOF

# allow 1password unlock, etc. with fingerprint
CopyFileTo /polkit-1.pam.conf /etc/pam.d/polkit-1

cat >"$(CreateFile /etc/polkit-1/rules.d/49-profile-admin.rules)" <<EOF
polkit.addAdminRule(function(action, subject) {
    return ["unix-user:${cfg_user}", "unix-group:wheel"];
});
EOF

CopyFileTo /logind.conf /etc/systemd/logind.conf
CopyFileTo /mkinitcpio.conf /etc/mkinitcpio.conf
CopyFileTo /safe-rm.conf /etc/safe-rm.conf

cat >"$(CreateFile /etc/environment)" <<'EOF'
NIX_CONFIG="extra-experimental-features = nix-command flakes"
EOF

sed -i '\|^Include = /etc/pacman.d/mirrorlist$|i CacheServer = https://archive.archlinux.org/packages/.all' \
    "$(GetPackageOriginalFile pacman /etc/pacman.conf)"

make_pkg_conf=$(GetPackageOriginalFile pacman '/etc/makepkg.conf')
echo MAKEFLAGS=\"-j$(nproc)\" >>$make_pkg_conf

AddPackage --foreign preload # Makes applications run faster by prefetching binaries and shared objects
SystemdEnable preload /usr/lib/systemd/system/preload.service

SetFileProperty / mode 555
