{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bc
    feh
    acpi
    vim
    wget
    curl
    tmux
    ripgrep
    gnupg
    nmap
    bat
    bash
    killall
    less
    more
    netcat
    rsync
    tree
    xclip
    zip
    unzip
    git
    p7zip
    lsd
    fzf
    fish
    sbt
    gcc
    rustup
    rustc
    go
    nodejs
    gnugrep
    pciutils
    any-nix-shell
    fishPlugins.foreign-env

    llvm
    bazelisk
    gnumake
    autoconf
    automake
    libtool
    autoreconfHook
    pkgconfig
    m4
    utillinux
    procps
    (callPackage ./pkgs/pywalfox-native.nix {})
  ];
}

