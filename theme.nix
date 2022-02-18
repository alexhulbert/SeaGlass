{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pywal
  ];
}

