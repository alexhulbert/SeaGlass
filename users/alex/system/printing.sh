AddPackage cups
AddPackage avahi
AddPackage nss-mdns
AddPackage --foreign brlaser

CopyFileTo /nsswitch.conf /etc/nsswitch.conf
SystemdEnable avahi /usr/lib/systemd/system/avahi-daemon.service
SystemdEnable avahi /usr/lib/systemd/system/avahi-daemon.socket
SystemdEnable cups /usr/lib/systemd/system/cups.service
SystemdEnable cups /usr/lib/systemd/system/cups.socket
SystemdEnable cups /usr/lib/systemd/system/cups.path

IgnorePath '/etc/cups/classes.conf*'
IgnorePath '/etc/cups/printers.conf*'
IgnorePath '/etc/cups/ppd/*'
