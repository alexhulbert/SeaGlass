{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jdk11
    virtualbox
  ];

  virtualisation.docker.enable = true;
}

