{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };

  generateService = serviceName: (command: {
    Unit = {
      Description = "${serviceName} Service";
      PartOf = [ "hyprland.target" ];
    };
    Install = {
      WantedBy = [ "hyprland.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "/usr/bin/env ${command}";
      RestartSec = "1";
    };
  });
in {

  home.file.".hushlogin".text = "";

  programs.zsh.profileExtra = ''
    if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      exec zsh -c "Hyprland | logger -t hyprland; systemctl --user stop hyprland.target"
    fi
  '';

  systemd.user = {
    targets.hyprland.Unit = {
      Description = "Graphical Target, starts with wayland";
      Requires = "user-path-import.service";
      After = "user-path-import.service";
    };
    services = {
      ags = (generateService "ags" "ags");
      swayosd = (generateService "swayosd" "swayosd-server");
      ulauncher = (generateService "ulauncher" "ulauncher --hide-window --no-window --no-window-shadow");
      plasma-waybar = (generateService "plasma-waybar" "plasma-waybar");
      waybar = (generateService "waybar" "waybar");
      polkit-kde-auth = (generateService "polkit-kde-auth" "/usr/lib/polkit-kde-authentication-agent-1");
      powerdevil = (generateService "powerdevil" "/usr/lib/org_kde_powerdevil");
      xdg-desktop-portal-hyprland = (generateService "xdg-desktop-portal-hyprland" "/usr/lib/xdg-desktop-portal-hyprland");
      kde-connect = (generateService "kde-connect" "/usr/lib/kdeconnectd");
      kded = (generateService "kded" "kded5");
      pyprland = (generateService "pyprland" "pypr");
      hyprwalld = (generateService "hyprwalld" "hyprwalld");
      xsettingsd = (generateService "xsettingsd" "xsettingsd");
    };
  };

  systemd.user.services.user-path-import = {
    Unit.Description = "Import PATH from zsh";
    Install.WantedBy = ["hyprland.target"];
    Service = {
      Type = "oneshot";
      ExecStart = "/usr/bin/zsh -lc 'systemctl --user import-environment PATH'";
    };
  };

  systemd.user.services.kded-modules = {
    Unit = {
      Description = "KDED Modules";
      After = [ "kded.service" ];
      PartOf = [ "kded.service" ];
    };
    Install = {
      WantedBy = [ "hyprland.target" ];
    };
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
          qdbus org.kde.kded5 /kded org.kde.kded5.loadModule $module
        done
      ''}";
      RemainAfterExit = true;
    };
  };
}