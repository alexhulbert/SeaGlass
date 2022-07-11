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
in {
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager = {
      defaultSession = "plasma5+i3";
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "alex";
      };
      session = [
        {
          manage = "desktop";
          name = "plasma5+i3";
          start = ''exec env KDEWM=${pkgs.i3-gaps}/bin/i3 ${pkgs.plasma-workspace}/bin/startplasma-x11'';
        }
      ];
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
  };

  environment.systemPackages = with pkgs; [
    libxslt
    unstable.kicad-unstable-small
    remmina
    freerdp
    mpv
    miraclecast
    i3
    qbittorrent
    jetbrains.idea-community
    (vscode-with-extensions.override { vscodeExtensions = extensions; })
    # (glass.patch_vscode (callPackage ./pkgs/vscode.nix {}) glass.default_theme_vscode)
    spectacle
    gparted
    bibata-cursors
    wpgtk
    konsole
    plasma-nm
    qtcurve
    lxqt.pavucontrol-qt
    unstable.plasma5Packages.lightly
    plasma5Packages.plasma-applet-virtual-desktop-bar
    unstable.lightly-qt
    torbrowser
    monero-gui
    kleopatra
    chromium
    ark
    kdiff3
    obs-studio
    filelight
    (callPackage ./pkgs/hud-menu {})
  ];
}

