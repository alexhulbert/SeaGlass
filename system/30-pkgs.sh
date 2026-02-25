# base pkgs

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage dosfstools # DOS filesystem utilities
AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage clang # C language family frontend for LLVM
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel
AddPackage os-prober # Utility to detect other OSes on a set of drives
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux
AddPackage rustup # The Rust toolchain installer
AddPackage nix # A purely functional package manager
AddPackage git # the fast distributed version control system
AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX
AddPackage sof-firmware # Sound Open Firmware
AddPackage fuse2 # A library that makes it possible to implement a filesystem in a userspace program.
AddPackage nodejs # Evented I/O for V8 javascript ("Current" release)
AddPackage npm # A package manager for JavaScript
AddPackage libvips # A fast image processing library with low memory needs
AddPackage pkgfile # a pacman .files metadata explorer
AddPackage pipewire # Low-latency audio/video router and processor
AddPackage pipewire-pulse # Low-latency audio/video router and processor - PulseAudio replacement
AddPackage wireplumber # Session / policy manager implementation for PipeWire
AddPackage bluez-utils # Development and debugging utilities for the bluetooth protocol stack
AddPackage python-pipx # Install and Run Python Applications in Isolated Environments
AddPackage tailscale # A mesh VPN that makes it easy to connect your devices, wherever they are.
AddPackage ntfs-3g # NTFS filesystem driver and utilities
AddPackage sshfs # FUSE client based on the SSH File Transfer Protocol
AddPackage jdk17-openjdk # OpenJDK Java 17 development kit
AddPackage jdk21-openjdk # OpenJDK Java 21 development kit
AddPackage alsa-firmware # Firmware binaries for loader programs in alsa-tools and hotplug firmware loader
AddPackage fprintd # D-Bus service to access fingerprint readers
AddPackage interception-tools # A minimal composable infrastructure on top of libudev and libevdev
AddPackage wtype # xdotool type for wayland
AddPackage kdialog # A utility for displaying dialog boxes from shell scripts
AddPackage --foreign python-thefuzz # Fuzzy string matching like a boss
AddPackage fwupd # Simple daemon to allow session software to update firmware
AddPackage go # Core compiler tools for the Go programming language

# latex
AddPackage texlive-fontsextra # TeX Live - Additional fonts
AddPackage texlive-latexextra # TeX Live - LaTeX additional packages
AddPackage texlive-latexrecommended # TeX Live - LaTeX recommended packages

# base aur pkgs

AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
AddPackage --foreign paru # Feature packed AUR helper

