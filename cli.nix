{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") { };
  comma = import (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "comma";
    rev = "67f26046b946f1eceb7e4df36875fef91cf39a04";
    sha256 = "0sar50z1x7l33ayxyy4w1jfc7lx71xrnsa1wlhdq9pldiszz45v5";
  }) {};
in {
  environment.systemPackages = with pkgs; [
    distrobox
    minikube kubectl kubernetes
    python39Packages.ipython
    python39Packages.bootstrapped-pip
    fprintd
    steam-run
    bc
    feh
    acpi
    neovim
    wget curl
    iodine
    tmux
    ripgrep
    gnupg
    pinentry
    nmap
    sshfs
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
    fzf
    # cod
    fish
    sbt
    gcc
    go
    nodejs
    gnugrep
    pciutils
    xdotool
    docker
    bind
    any-nix-shell
    fishPlugins.foreign-env
    exa bat fd
    comma

    android-tools
    ffmpeg
    spotify-tui
    python310
    qemu
    python39Packages.rpm
    packer  
    patchelf
    nix-index
    bintools-unwrapped
    rnix-lsp
    llvm
    unstable.bazel_5
    gnumake
    autoconf
    automake
    libtool
    autoreconfHook
    pkgconfig
    m4
    utillinux
    procps
    vorbis-tools
    rustup
    wineWowPackages.unstable
    winetricks
    wineasio
    samba4Full
    mullvad
    mullvad-vpn
    texlive.combined.scheme-full
  ];
}

