IgnorePackage --foreign bitwig-studio # Music production and performance system.
AddPackage --foreign monero-gui-static-bin # Monero: the secure, private, untraceable peer-to-peer currency
AddPackage kleopatra # Certificate Manager and Unified Crypto GUI
AddPackage qbittorrent # An advanced BitTorrent client programmed in C++, based on Qt toolkit and libtorrent-rasterbar
AddPackage --foreign mullvad-vpn-bin # The Mullvad VPN client app for desktop
AddPackage --foreign prismlauncher-qt5-bin # Minecraft launcher with ability to manage multiple instances.
AddPackage obs-studio # Free, open source software for live streaming and recording
AddPackage godot # Advanced cross-platform 2D and 3D game engine
AddPackage --foreign cassowary # Run Windows Applications inside a VM on Linux as if they are native.
AddPackage --foreign moonlight-qt # GameStream client for PCs (Windows, Mac, and Linux)
AddPackage --foreign fx_cast-bin # Implementation of the Google Cast Chrome Sender SDK within Firefox
AddPackage --foreign flashprint # Slicer for the FlashForge 3D printers.
AddPackage --foreign platformio # A cross-platform code builder and library manager
AddPackage openscad # The programmers solid 3D CAD modeller

# for work
AddPackage --foreign yocto-nanbield-meta # Yocto Nanbield project build dependencies
AddPackage cargo-nextest # A next-generation test runner for Rust.
AddPackage fuse-overlayfs # FUSE implementation of overlayfs
AddPackage gocryptfs # Encrypted overlay filesystem written in Go.
AddPackage podman # Tool and library for running OCI-based containers in pods
AddPackage musl # Lightweight implementation of C standard library
AddPackage repo # The Multiple Git Repository Tool from the Android Open Source Project
IgnorePath '/etc/fuse.conf'

CopyFileTo /FlashPrint5.desktop /usr/share/applications/FlashPrint5.desktop