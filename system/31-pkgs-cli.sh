AddPackage --foreign cod # A completion daemon for bash/zsh
AddPackage --foreign gksu # A graphical frontend for su
AddPackage acpi # Client for battery, power, and thermal readings
AddPackage brightnessctl # Lightweight brightness control tool
AddPackage docker # Pack, ship and run any application as a lightweight container
AddPackage rsync # A fast and versatile file copying tool for remote and local files
AddPackage snapper # A tool for managing BTRFS and LVM snapshots. It can create, diff and restore snapshots and provides timelined auto-snapping.

# cli tools
AddPackage android-tools # Android platform tools
AddPackage --foreign android-apktool-bin # A tool for reverse engineering Android .apk files
AddPackage --foreign android-sdk-cmdline-tools-latest # Android SDK Command-line Tools (latest)
AddPackage --foreign android-sdk-platform-tools # Platform-Tools for Google Android SDK (adb and fastboot)
AddPackage bat # Cat clone with syntax highlighting and git integration
AddPackage bc # An arbitrary precision calculator language
AddPackage eza # A modern replacement for ls (community fork of exa)
AddPackage fd # Simple, fast and user-friendly alternative to find
AddPackage fzf # Command-line fuzzy finder
AddPackage jujutsu # Git-compatible VCS that is both simple and powerful
AddPackage zoxide # A smarter cd command for your terminal
AddPackage mosh # Mobile shell, surviving disconnects with local echo and line editing
AddPackage openbsd-netcat # TCP/IP swiss army knife. OpenBSD variant.
AddPackage httpie # human-friendly CLI HTTP client for the API era
AddPackage less # A terminal based program for viewing text files
AddPackage man-db # A utility for reading man pages
AddPackage ffmpeg # Complete solution to record, convert and stream audio and video
AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage 7zip # File archiver for extremely high compression
AddPackage ripgrep # A search tool that combines the usability of ag with the raw speed of grep
AddPackage tree # A directory listing program displaying a depth indented list of files
AddPackage unzip # For extracting and viewing files in .zip archives
AddPackage wget # Network utility to retrieve files from the Web
AddPackage zip # Compressor/archiver for creating and modifying zipfiles
AddPackage inotify-tools # inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.
AddPackage inetutils # A collection of common network programs
AddPackage samply # A command-line sampling profiler for macOS and Linux
AddPackage jq # Command-line JSON processor
AddPackage yq # Command-line YAML, XML, TOML processor - jq wrapper for YAML/XML/TOML documents
AddPackage cpupower # Linux kernel tool to examine and tune power saving related features of your processor
AddPackage diffoscope # Tool for in-depth comparison of files, archives, and directories
AddPackage nmap # Utility for network discovery and security auditing
AddPackage reptyr # Utility for taking an existing running program and attaching it to a new terminal
AddPackage postgresql # Sophisticated object-relational DBMS
AddPackage screen # Full-screen window manager that multiplexes a physical terminal
AddPackage yt-dlp # A youtube-dl fork with additional features and fixes
AddPackage yubikey-manager # Python library and command line tool for configuring a YubiKey
AddPackage nvtop # GPUs process monitoring for AMD, Intel and NVIDIA
AddPackage net-tools # Configuration tools for Linux networking
AddPackage strace # A diagnostic, debugging and instructional userspace tracer
AddPackage --foreign pacdate # Automates downgrading packages to a specific date
AddPackage --foreign intentrace # strace with intent, it goes all the way for you instead of half the way
AddPackage htop # Interactive process viewer
AddPackage jless # A command-line pager for JSON data
AddPackage btop # A monitor of system resources, bpytop ported to C++
AddPackage tinyxxd # Standalone version of the hex dump utility that comes with ViM
AddPackage --foreign safe-rm # A tool intended to prevent the accidental deletion of important files
CopyFile /etc/safe-rm.conf
