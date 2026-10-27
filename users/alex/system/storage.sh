cat >"$(CreateFile /etc/fstab)" <<'EOF'
LABEL=root / btrfs rw,relatime,subvol=@ 0 0
LABEL=root /var btrfs rw,relatime,subvol=@var 0 0
LABEL=root /home btrfs rw,relatime,subvol=@home 0 0
LABEL=BOOT /boot vfat rw,relatime,nofail,x-systemd.before=local-fs.target,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2
/dev/mapper/cryptswap none swap defaults 0 0
EOF

cat >"$(CreateFile /etc/crypttab)" <<'EOF'
cryptswap UUID=344ad90e-3471-468b-bcc4-e4aedd2d4ed1 none luks
EOF

cat >"$(CreateFile /boot/loader/loader.conf 755)" <<'EOF'
default arch
timeout 0
editor no
console-mode keep
EOF

cat >"$(CreateFile /boot/loader/entries/arch.conf 755)" <<'EOF'
title Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options quiet splash loglevel=3 systemd.show_status=false rd.systemd.show_status=false vt.global_cursor_default=0 i915.enable_psr=0 i915.enable_dc=0 rd.luks.name=d7a364e0-bc9a-4525-b90e-7ba1503a9096=system rd.luks.name=344ad90e-3471-468b-bcc4-e4aedd2d4ed1=cryptswap root=/dev/mapper/system rootflags=subvol=@ rw i915.enable_dpcd_backlight=1
EOF
