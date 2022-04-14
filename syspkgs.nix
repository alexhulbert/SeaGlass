{ config, pkgs, ... }:

let
  sf-font = pkgs.callPackage ./pkgs/sf-font.nix {};
in {
  environment.systemPackages = with pkgs; [
    networkmanager
    docker
    nix
    wpa_supplicant
    nerdfonts
    crudini
    cron
    sf-font
  ];

  fonts.fonts = [ pkgs.nerdfonts sf-font ];

  /*services.cron = {
    enable = true;
    systemCronJobs = [
      "@daily root find /home/alex/Downloads/* -mtime +6 -type f -delete"
    ];
  };*/
}

