{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
in {
  # plasma theme
  xdg.dataFile = {
    "plasma/look-and-feel/seaglass".source = ./resources/theme/kde-theme;
  };

  # force disable splash screen
  xdg.configFile.ksplashrc.text = ''
    [KSplash]
    Engine = "None";
    Theme = "None";
  '';

  # theme randomizer autostart script
  xdg.configFile."plasma-workspace/env/set-theme.sh".source = pkgs.writeScript "set-wallpaper.sh"   ''
      cd ${./resources/theme}
      ./theme.sh ~/wallpaper/$(ls ~/wallpaper | shuf -n 1)
  '';

  # albert config
  programs.plasma.configFile."albert.conf" = {
    General = {
      frontend = "widgetsboxmodel";
      hotkey = "Ctrl+Alt+Shift+Meta+F12";
      showTray = false;
    };
    applications_xdg.enabled = true;
    calculator_qalculate.enabled = true;
    widgetsboxmodel = {
      theme = "Pywal";
      clientShadow = false;
    };
  };
  xdg.configFile."wal/templates/colors-albert.qss".source = ./resources/theme/colors-albert.qss;
  xdg.configFile."autostart/albert.desktop".source = config.lib.file.mkOutOfStoreSymlink "/usr/share/applications/albert.desktop";

  # context menu hud
  xdg.configFile."wal/templates/hud.rasi".source = ./resources/theme/hud.rasi;
  programs.rofi = {
    enable = true;
    package = shim {
      name = "rofi";
      cmds = ["rofi"];
    };
    theme = "${config.xdg.cacheHome}/wal/hud.rasi";
  };
  systemd.user.services.plasma-hud = {
    Service = {
      ExecStart = "/usr/lib/plasma-hud/plasma-hud";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Unit = {
      After = ["graphical-session-pre.target"];
      Description = "Plasma HUD";
      PartOf = ["graphical-session.target"];
    };
  };

  # konsole
  xdg.dataFile."konsole/Pywal.profile".source = ./resources/konsole.profile;
  xdg.dataFile."kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;
  programs.plasma.configFile.konsolerc = {
    "Desktop Entry" = {
      DefaultProfile = "Pywal.profile";
    };
    MainWindow = {
      MenuBar = "Disabled";
      StatusBar = "Disabled";
      ToolBarsMovable = "Disabled";
      State =
        "AAAA/wAAAAD9AAAAAAAAB1MAAAjMAAAABAAAAAQAAAAIAAAACPw" +
        "AAAABAAAAAgAAAAIAAAAWAG0AYQBpAG4AVABvAG8AbABCAGEAcg" +
        "AAAAAA/////wAAAAAAAAAAAAAAHABzAGUAcwBzAGkAbwBuAFQAb" +
        "wBvAGwAYgBhAHIAAAAAAP////8AAAAAAAAAAA==";
    };
  };
}
