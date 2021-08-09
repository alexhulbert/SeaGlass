{ config, pkgs, ... }:

{
  # imports = [
  #   ./pkgs/i3-hud-menu.nix
  # ];
  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasma5+i3";

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };

  services.picom.enable = true;

  hardware.opengl.driSupport32Bit = true;
  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  environment.systemPackages = with pkgs; [
    i3
    qbittorrent
    firefox
    jetbrains.idea-community
    vscode
    spectacle
    gparted
    spotify
    konsole
    plasma-nm
    lxqt.pavucontrol-qt
    torbrowser
    monero-gui
    kleopatra
    obs-studio
    (callPackage ./pkgs/i3-hud-menu.nix {})
    # (callPackage(builtins.fetchurl "https://bit.ly/parsec-nix" {}))
  ];
}

