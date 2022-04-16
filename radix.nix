{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jdk11
  ];

  virtualisation.docker.enable = true;
}

