{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adoptopenjdk-openj9-bin-11
  ];
}

