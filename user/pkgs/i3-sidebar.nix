{ config, pkgs, ... }: 
let
  i3-sidebar = pkgs.yarn2nix-moretea.mkYarnPackage {
    name = "i3-sidebars";
    src = ../resources/i3-sidebar;
    packageJSON = ../resources/i3-sidebar/package.json;
    yarnLock = ../resources/i3-sidebar/yarn.lock;
  };
in {
  config.home.packages = [ i3-sidebar ];
  config.systemd.user.services.i3-sidebar = {
    Service = {
      ExecStart = "${i3-sidebar}/bin/i3-sidebar -d";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      After = [ "graphical-session-pre.target" ];
      Description = "i3 Sidebar Daemon";
      PartOf = [ "graphical-session.target" ];
    };
  };
}