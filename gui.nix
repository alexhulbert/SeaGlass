{ config, pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "wal-theme";
    publisher = "dlasagno";
    version = "1.1.0";
    sha256 = "14va122bjwmns92jpckm696bnl32jgm7nk3m9w2niasa47dzg3k3";
  }];
  # glass = (pkgs.callPackage ./libs/glass.nix {});
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  fxcast = unstable.fx_cast_bridge.overrideAttrs(o: {
    version = "0.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "hensm";
      repo = "fx_cast";
      rev = "v0.3.1";
      hash = "sha256-hB4NVJW2exHoKsMp0CKzHerYgj8aR77rV+ZsCoWA1Dg=";
    };
  });
in {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };


  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "alex";
      };
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
    xkbOptions = "ctrl:nocaps";
  };

  services.dbus.packages = [pkgs.miraclecast];

  hardware.opengl.driSupport32Bit = true;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  environment.variables = {
    QT_QPA_PLATFORMTHEME = "kde";
    MOZ_USE_XINPUT2 = "1";
    GTK_THEME = "FlatColor:dark";
  };

  programs.wireshark.enable = true;
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    prismlauncher-qt5
    fxcast
    libxslt
    unstable.kicad-unstable-small
    spotify
    remmina
    mpv
    miraclecast
    unstable.jellyfin-media-player
    i3
    qbittorrent
    jetbrains.idea-community
    (vscode-with-extensions.override { vscodeExtensions = extensions; })
    spectacle
    gparted
    bibata-cursors
    wpgtk
    konsole
    plasma-nm
    qtcurve
    lxqt.pavucontrol-qt
    plasma5Packages.lightly
    plasma5Packages.plasma-applet-virtual-desktop-bar
    lightly-qt
    xdg-desktop-portal-kde
    tor-browser-bundle-bin
    monero-gui
    kleopatra
    chromium
    ark
    kdiff3
    obs-studio
    filelight
    dolphin-emu-beta
    (callPackage ./pkgs/hud-menu {})
  ];
}

