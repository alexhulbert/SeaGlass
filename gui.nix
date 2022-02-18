{ config, pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
  ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
    name = "wal-theme";
    publisher = "dlasagno";
    version = "1.1.0";
    sha256 = "14va122bjwmns92jpckm696bnl32jgm7nk3m9w2niasa47dzg3k3";
  }];
in {
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasma5+i3";
  services.xserver.displayManager.sddm.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  services.picom.enable = true;

  hardware.opengl.driSupport32Bit = true;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  environment.variables = {
    "QT_QPA_PLATFORMTHEME" = "kde";
  };

  environment.systemPackages = with pkgs; [
    i3
    qbittorrent
    (firefox-bin.override {
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePocket = true;
        DisableTelemetry = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
        PasswordManagerEnabled = false;
      };
    })
    jetbrains.idea-community
    (vscode-with-extensions.override { vscodeExtensions = extensions; })
    spectacle
    gparted
    spotify
    konsole
    plasma-nm
    qtcurve
    lxqt.pavucontrol-qt
    torbrowser
    monero-gui
    kleopatra
    ark
    obs-studio
    (callPackage ./pkgs/i3-hud-menu.nix {})
    # (callPackage(builtins.fetchurl "https://bit.ly/parsec-nix" {}))
  ];
}

