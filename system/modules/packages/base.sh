AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage dosfstools # DOS filesystem utilities
AddPackage clang # C language family frontend for LLVM
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage os-prober # Utility to detect other OSes on a set of drives
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage linux-firmware # Firmware files for Linux
AddPackage rustup # The Rust toolchain installer
AddPackage nix # A purely functional package manager
AddPackage git # the fast distributed version control system
AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX
AddPackage fuse2 # A library that makes it possible to implement a filesystem in a userspace program.
AddPackage nodejs # Evented I/O for V8 javascript ("Current" release)
AddPackage npm # A package manager for JavaScript
AddPackage pkgfile # a pacman .files metadata explorer
AddPackage pipewire # Low-latency audio/video router and processor
AddPackage pipewire-pulse # Low-latency audio/video router and processor - PulseAudio replacement
AddPackage pipewire-alsa # Route ALSA applications through PipeWire
AddPackage wireplumber # Session / policy manager implementation for PipeWire
AddPackage bluez-utils # Development and debugging utilities for the bluetooth protocol stack
AddPackage bluez
AddPackage networkmanager
AddPackage tailscale # A mesh VPN that makes it easy to connect your devices, wherever they are.
AddPackage ntfs-3g # NTFS filesystem driver and utilities
AddPackage wtype # xdotool type for wayland
AddPackage fwupd # Simple daemon to allow session software to update firmware
AddPackage go # Core compiler tools for the Go programming language

# base aur pkgs

AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
AddPackage --foreign paru # Feature packed AUR helper
