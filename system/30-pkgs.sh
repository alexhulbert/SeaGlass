# base pkgs

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage intel-ucode # Microcode update files for Intel CPUs
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage grub # GNU GRand Unified Bootloader (2)
AddPackage grub-btrfs # Include btrfs snapshots in GRUB boot options
AddPackage os-prober # Utility to detect other OSes on a set of drives
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux
AddPackage rustup # The Rust toolchain installer
AddPackage nix # A purely functional package manager
AddPackage git # the fast distributed version control system

# base aur pkgs

AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
AddPackage --foreign paru # Feature packed AUR helper
