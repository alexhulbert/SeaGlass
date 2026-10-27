AddPackage firefox # Standalone web browser from mozilla.org
AddPackage vlc # Free and open source cross-platform multimedia player and framework
AddPackage xsettingsd # Provides settings to X11 applications via the XSETTINGS specification
AddPackage plymouth # Graphical boot splash screen
LocalPackage "https://github.com/alexhulbert/plymouth-seaglass.git" "9a64e5f9ae0c3c8a3ccc142542b39c167868df37"
AddPackage --foreign wezterm-git # A terminal emulator implemented in Rust, using OpenGL ES 2 for rendering.

AddPackage --foreign visual-studio-code-bin # Visual Studio Code (vscode): Editor for building and debugging modern web and cloud applications (official binary version)
AddPackage gparted # A Partition Magic clone, frontend to GNU Parted
AddPackage papers # Document viewer for PDF and other document formats aimed at the GNOME desktop
AddPackage loupe
AddPackage gnome-text-editor
AddPackage bazaar
AddPackage --foreign doubletake-bin
AddPackage gst-plugin-pipewire
AddPackage gst-plugin-va
AddPackage nautilus # GNOME file manager
AddPackage gvfs-smb
PatchPackage sushi "$cfg_root/patches/sushi.patch"
AddPackage gst-plugins-good # Common audio/video formats for Sushi previews
AddPackage gst-plugins-bad # Additional media codecs and parsers for previews
AddPackage gst-libav # FFmpeg decoders for H.264, AAC and other media previews
AddPackage ark # Archiving Tool
AddPackage gimp # GNU Image Manipulation Program
AddPackage --foreign google-chrome # The popular web browser by Google (Stable Channel)
AddPackage --foreign 1password # Password manager and secure wallet

# fonts
AddPackage ttf-firacode-nerd # Patched font Fira (Fura) Code from nerd fonts library
AddPackage --foreign apple-fonts # Apple San Francisco, New York fonts, directly from Apple official source
AddPackage noto-fonts-emoji # Google Noto emoji fonts
AddPackage adobe-source-han-sans-otc-fonts # Adobe Source Han Sans - Pan-CJK OpenType/CFF Collection fonts
AddPackage adobe-source-han-serif-otc-fonts # Adobe Source Han Serif - Pan-CJK OpenType/CFF Collection fonts

# spotify
AddPackage --foreign spotify # A proprietary music streaming service

AddPackage pavucontrol-qt # A Pulseaudio mixer in Qt (port of pavucontrol)
AddPackage kdeconnect # Adds communication between KDE and your smartphone
AddPackage power-profiles-daemon # Makes power profiles handling available over D-Bus
AddPackage rtkit # Realtime scheduling for PipeWire
AddPackage playerctl # Media-key controls
AddPackage --foreign tzupdate

# theming
AddPackage papirus-icon-theme # Papirus icon theme
AddPackage --foreign darkly-bin # A modern style for qt applications.
AddPackage --foreign darkly-qt5-git
AddPackage --foreign qtengine
AddPackage --foreign bibata-cursor-theme-bin # Material Based Cursor Theme

# wayland / hyprland specific
PatchPackage aquamarine "$cfg_root/patches/aquamarine.patch"
AddPackage hyprland # a highly customizable dynamic tiling Wayland compositor
AddPackage hyprpm
AddPackage uwsm
AddPackage grim # Screenshot portal
AddPackage slurp # Portal region selection
AddPackage wl-clipboard # Wayland clipboard commands
PatchPackage dux-shell-git "$cfg_root/patches/dms/audio-availability.patch" "$cfg_root/patches/dms/hide-special-workspaces.patch"
AddPackage --foreign dux-calendar-bin
AddPackage matugen
AddPackage adw-gtk-theme
AddPackage dgop
AddPackage --foreign hyprmoncfg-bin
PatchPackage handy "$cfg_root/patches/handy.patch"
AddPackage hyprwayland-scanner # A Hyprland implementation of wayland-scanner, in and for C++
AddPackage xdg-desktop-portal-hyprland # xdg-desktop-portal backend for hyprland
AddPackage --foreign hyprland-preview-share-picker-git
AddPackage xdg-desktop-portal-gtk # GTK file dialogs and desktop portal fallback
AddPackage libdbusmenu-glib # Firefox menu export support
AddPackage libdbusmenu-gtk3 # Firefox GTK menu export support

# hyprland deps
AddPackage cmake # A cross-platform open-source make system
AddPackage cpio # A tool to copy files into or out of a cpio or tar archive
AddPackage meson # High productivity build system
AddPackage glm # C++ mathematics library for 3D software based on the OpenGL Shading Language (GLSL) specification
AddPackage glaze # An Extremely fast, In-Memory JSON and Interface Library for Modern C++
