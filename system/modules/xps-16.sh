PinPackage linux 7.2.9.arch1-1
PinPackage linux-headers 7.2.9.arch1-1
AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage sof-firmware # Sound Open Firmware
AddPackage alsa-firmware # Firmware binaries for loader programs in alsa-tools and hotplug firmware loader
AddPackage fprintd # D-Bus service to access fingerprint readers
AddPackage keyd
PinPackage nvidia-open 615.78.08-1
PinPackage nvidia-utils 615.78.08-1
AddPackage libva-nvidia-driver # VA-API implementation that uses NVDEC as a backend
AddPackage intel-media-driver # Intel Media Driver for VAAPI — Broadwell+ iGPUs
AddPackage vulkan-intel
PinPackage opencl-nvidia 615.78.08-1

SystemdEnable keyd /usr/lib/systemd/system/keyd.service
CopyFileTo /keyd.conf /etc/keyd/xps.conf

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

SystemdEnable nvidia-utils /usr/lib/systemd/system/nvidia-powerd.service

cat <<EOF >"$(CreateFile /etc/udev/rules.d/90-backlight.rules)"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/usr/bin/chgrp $(id -gn "$cfg_user") /sys%p/brightness", RUN+="/usr/bin/chmod g+w /sys%p/brightness"
EOF
