# set default mic profile
cat <<EOF >| "$(CreateFile '/etc/pulse/default.pa.d/mic-profile.pa')"
set-card-profile alsa_card.pci-0000_00_1f.3-platform-sof_sdw "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic, Speaker)"
EOF

# copilot key remapping
SystemdEnable interception-tools /usr/lib/systemd/system/udevmon.service
CopyFileTo /udevmon.yaml /etc/interception/udevmon.yaml
CopyFileTo /copilot.hwdb /etc/udev/hwdb.d/20-copilot.hwdb
CopyFileTo /copilot2ctrl /usr/local/bin/copilot2ctrl 755