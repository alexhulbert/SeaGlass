{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanager
    docker
    nix
    wpa_supplicant
    nerdfonts
    crudini
    cron
  ];

  fonts.fonts = [ pkgs.nerdfonts ];

  /*services.cron = {
    enable = true;
    systemCronJobs = [
      "@daily root find /home/alex/Downloads/* -mtime +6 -type f -delete"
    ];
  };*/
}

