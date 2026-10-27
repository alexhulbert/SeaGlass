source "$cfg_root/system/modules/ignores.sh"
source "$cfg_root/system/modules/base.sh"
source "$cfg_root/system/modules/desktop.sh"
source "$cfg_root/users/alex/ableton/system.sh"
source "$cfg_root/system/modules/xps-16.sh"
source "$cfg_root/users/$cfg_user/system/storage.sh"
source "$cfg_root/system/modules/packages/base.sh"
source "$cfg_root/system/modules/packages/cli.sh"
source "$cfg_root/system/modules/packages/desktop.sh"
source "$cfg_root/users/$cfg_user/system/packages.sh"
source "$cfg_root/users/$cfg_user/system/printing.sh"
source "$cfg_root/users/$cfg_user/system/chatgpt.sh"

cat >"$(CreateFile /usr/share/google-chrome/extensions/jcnpigfegdnmjlbkgmabckmkekmjgoin.json)" <<'EOF'
{"external_update_url": "https://github.com/alexhulbert/coloreader/releases/latest/download/updates.xml"}
EOF

cat >"$(CreateFile /etc/udev/hwdb.d/10-caps.hwdb)" <<'EOF'
evdev:atkbd:dmi:bvn*:bvr*:bd*:svn*:pn*:pvr*
 KEYBOARD_KEY_3a=calc

evdev:input:*
 KEYBOARD_KEY_70039=calc
EOF

cat <<EOF >|"$(CreateFile '/etc/udev/rules.d/40-serial.rules')"
KERNEL=="ttyUSB[0-9]*",MODE="0666"
KERNEL=="ttyACM[0-9]*",MODE="0666"
EOF
