{ config
, pkgs
, lib
, ...
}:
let
  generateServiceWith = serviceName: command: extra:
    lib.mkMerge [ (generateService serviceName command) extra ];

  generateService = serviceName: command: {
    Unit = {
      Description = "${serviceName} Service";
      PartOf = [ "hyprland.target" ];
      Requires = [ "hyprland.target" ];
      After = [ "user-path-import.service" ];
    };
    Install.WantedBy = [ "hyprland.target" ];
    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "/usr/bin/env ${command}";
      RestartSec = "1";
    };
  };
in
{

  home.file.".hushlogin".text = "";

  programs.zsh.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec zsh -c "Hyprland | logger -t hyprland; sleep 10; systemctl --user stop hyprland.target"
    fi
  '';

  systemd.user = {
    targets.hyprland.Unit = {
      Description = "Graphical Target, starts with wayland";
      Requires = [ "user-path-import.service" ];
      After = [ "user-path-import.service" ];
    };
    services = {
      ags = (generateService "ags" "ags");
      swayosd = (generateService "swayosd" "swayosd-server");
      ulauncher = (generateServiceWith "ulauncher" "ulauncher --hide-window --no-window --no-window-shadow" { Unit.After = [ "seaglass-theme.service" ]; });
      plasma-waybar = (generateServiceWith "plasma-waybar" "plasma-waybar" { Unit.After = [ "swaync.service" ]; });
      waybar = (generateServiceWith "waybar" "waybar" { Unit.After = [ "seaglass-theme.service" ]; });
      polkit-kde-auth = (generateService "polkit-kde-auth" "/usr/lib/polkit-kde-authentication-agent-1");
      powerdevil = (generateService "powerdevil" "/usr/lib/org_kde_powerdevil");
      xdg-desktop-portal-hyprland = (generateService "xdg-desktop-portal-hyprland" "/usr/lib/xdg-desktop-portal-hyprland");
      kde-connect = (generateService "kde-connect" "/usr/lib/kdeconnectd");
      kded = (generateService "kded" "kded6");
      pyprland = (generateService "pyprland" "pypr");
      swaync = (generateServiceWith "swaync" "swaync" { Unit.After = [ "seaglass-theme.service" ]; });
      hyprwatchd = (generateService "hyprwatchd" "hyprwatchd");
      dndwatchd = (generateService "dndwatchd" "dndwatchd");
      xsettingsd = (generateServiceWith "xsettingsd" "xsettingsd" { Service.Restart = lib.mkForce "always"; });
      xdg-home-cleaner = (generateService "xdg-home-cleaner" ./files/xdg-home-cleaner.sh);
    };
  };

  systemd.user.services.user-path-import = {
    Unit.Description = "Import PATH from zsh";
    Install.WantedBy = [ "hyprland.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "/usr/bin/zsh -lc 'systemctl --user import-environment PATH'";
      RemainAfterExit = true;
    };
  };

  systemd.user.services.seaglass-theme = {
    Unit = {
      Description = "Seaglass Theme";
      PartOf = [ "hyprland.target" ];
      After = [ "user-path-import.service" ];
    };
    Install.WantedBy = [ "hyprland.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "/usr/bin/env seaglass-theme";
      RemainAfterExit = true;
    };
  };

  systemd.user.services.kded-modules = {
    Unit = {
      Description = "KDED Modules";
      After = [ "kded.service" "user-path-import.service" ];
      PartOf = [ "kded.service" ];
    };
    Install.WantedBy = [ "hyprland.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeScript "start-kded-modules" ''
        #!/usr/bin/env zsh

        moduleNames=(
          "gtkconfig"
          "bluedevil"
          "networkmanagement"
          "networkstatus"
          "smbwatcher"
          "device_automounter"
        )

        for module in $moduleNames; do
          qdbus org.kde.kded6 /kded org.kde.kded6.loadModule $module
        done
      ''}";
      RemainAfterExit = true;
    };
  };
}
