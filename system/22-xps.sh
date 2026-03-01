# set default mic profile
cat <<EOF >| "$(CreateFile '/etc/pulse/default.pa.d/mic-profile.pa')"
set-card-profile alsa_card.pci-0000_00_1f.3-platform-sof_sdw "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic, Speaker)"
EOF

# copilot key remapping
SystemdEnable interception-tools /usr/lib/systemd/system/udevmon.service
CopyFileTo /udevmon.yaml /etc/interception/udevmon.yaml
CopyFileTo /copilot.hwdb /etc/udev/hwdb.d/20-copilot.hwdb
CopyFileTo /copilot2ctrl /usr/local/bin/copilot2ctrl 755

# ipu6 camera support
AddPackage libcamera                     # A complex camera support library for Linux, Android, and ChromeOS
AddPackage pipewire-libcamera            # Low-latency audio/video router and processor - Libcamera support
AddPackage v4l2loopback-utils            # v4l2-loopback device – utilities only
AddPackage libcamera-ipa                 # A complex camera support library for Linux, Android, and ChromeOS - signed IPA
AddPackage libcamera-tools               # A complex camera support library for Linux, Android, and ChromeOS - tools
AddPackage gst-plugin-libcamera          # Multimedia graph framework - libcamera plugin
AddPackage --foreign intel-ipu6-dkms-git # Intel IPU6 camera drivers
cat <<EOF >|"$(CreateFile '/etc/udev/rules.d/camera.rules')"
KERNEL=="udmabuf", TAG+="uaccess"
EOF