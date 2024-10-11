# kernel
IgnorePath '/boot/vmlinuz-*'
IgnorePath '/boot/lost+found'
IgnorePath '/boot/loader/*'
IgnorePath '/etc/mkinitcpio.d/linux.preset'
IgnorePath '/usr/lib/modules/*'
IgnorePath '/boot/*.img'
IgnorePath '/boot/EFI/*'
IgnorePath '/boot/grub/*'
IgnorePath '/boot/System Volume Information'

# pacman
IgnorePath '/etc/pacman.d/gnupg'
IgnorePath '/etc/pacman.d/mirrorlist'

# var subdirs
IgnorePath '/var/log/*'
IgnorePath '/var/tmp'
IgnorePath '/var/db'
IgnorePath '/var/spool'
IgnorePath '/var/lib'

# Haskell GHC
IgnorePath '/usr/lib/ghc-9.2.8'
IgnorePath '/usr/lib/ghc-9.2.8/*'

# certificates
IgnorePath '/etc/ca-certificates/extracted'
IgnorePath '/etc/ssl/certs'

# info
IgnorePath '/usr/share/info/dir'
IgnorePath '/usr/share/terminfo/w/wezterm'

# udev
IgnorePath '/etc/udev/hwdb.bin'
IgnorePath '/usr/lib/udev/hwdb.bin'

# file/folder types
IgnorePath '*.cache'
IgnorePath '*.lock'
IgnorePath '*.pyc'
IgnorePath '*.bak'
IgnorePath '*.OLD'
IgnorePath '*.pacnew'
IgnorePath '__pycache__'

# files with dynamically set permissions
IgnorePath '/usr/bin/groupmems'
IgnorePath '/usr/lib/utempter/*'
IgnorePath '/usr/share/polkit-1/rules.d'

# mime
IgnorePath '/usr/share/mime/*.xml' # Localizations
IgnorePath '/usr/share/mime/XMLnamespaces'
IgnorePath '/usr/share/mime/aliases' # MIME aliases
IgnorePath '/usr/share/mime/generic-icons'
IgnorePath '/usr/share/mime/globs' # File extensions
IgnorePath '/usr/share/mime/globs2' # Weighted file extensions?
IgnorePath '/usr/share/mime/icons'
IgnorePath '/usr/share/mime/magic' # Binary magic database
IgnorePath '/usr/share/mime/subclasses'
IgnorePath '/usr/share/mime/treemagic' # Directory magic
IgnorePath '/usr/share/mime/types'
IgnorePath '/usr/share/mime/version'

# fonts
IgnorePath '/etc/fonts/conf.d/*'
IgnorePath '/usr/share/fonts/*'
IgnorePath '/usr/share/glib-2.0/schemas/gschemas.compiled'

# docker
IgnorePath '/etc/docker/key.json'

# x11
IgnorePath '/etc/X11/xorg.conf'
IgnorePath '/etc/X11/xorg.conf.nvidia-xconfig-original'
IgnorePath '/etc/X11/xorg.conf.d/20-nvidia.conf'

# ruby
IgnorePath '/usr/lib/ruby/gems/*'

# spotify pywal
IgnorePath '/usr/share/spicetify-cli/Themes/Ziro/color.ini'

# latex
IgnorePath '/etc/texmf/*'
IgnorePath '/usr/share/texmf-dist/*'

# argcomplete
IgnorePath /etc/bash_completion.d/python-argcomplete
IgnorePath /usr/local/share/zsh/site-functions/_python-argcomplete
