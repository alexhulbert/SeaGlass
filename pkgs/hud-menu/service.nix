{ config, pkgs, ... }:

{
  config.systemd.user.services.hud-menu = {
    Service = {
      ExecStart = "${pkgs.callPackage ./default.nix {}}/bin/hud-menu-service";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      After = [ "graphical-session-pre.target" ];
      Description = "HUD Menu";
      PartOf = [ "graphical-session.target" ];
    };
  };
}