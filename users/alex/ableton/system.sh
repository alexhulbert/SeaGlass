cat >"$(CreateFile /etc/security/limits.d/90-seaglass-audio.conf)" <<EOF
${cfg_user} - memlock unlimited
${cfg_user} - rtprio 88
EOF

cat >"$(CreateFile "/etc/systemd/system/user@$(id -u "$cfg_user").service.d/audio.conf")" <<'EOF'
[Service]
LimitMEMLOCK=infinity
LimitRTPRIO=88
EOF

printf '%s\n' ntsync >"$(CreateFile /etc/modules-load.d/wine.conf)"
