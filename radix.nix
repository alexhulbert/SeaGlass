{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adoptopenjdk-openj9-bin-11
  ];

  virtualisation.docker.enable = true;
}

