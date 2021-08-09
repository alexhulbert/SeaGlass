{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    docker
    nix
    wpa_supplicant
    nerdfonts
    crudini
  ];
}

