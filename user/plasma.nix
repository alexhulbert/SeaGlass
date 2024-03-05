{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
in {
  home.file.".local/bin/seaglass-theme".source = config.lib.file.mkOutOfStoreSymlink
    "${builtins.toString ./.}/resources/theme/seaglass-theme.sh";

  programs.plasma = {
    configFile = {
      kdeglobals = {
        General = {
          fixed = "FiraCode Nerd Font,11,-1,5,50,0,0,0,0,0";
          font = "SFNS Display,11,-1,5,50,0,0,0,0,0";
          menuFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
          smallestReadableFont = "SFNS Display,9,-1,5,50,0,0,0,0,0";
          toolBarFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
          BrowserApplication = "firefox.desktop";
        };
        KDE = {
          LookAndFeelPackage = "seaglass";
          widgetStyle = "Lightly";
        };
      };
      dolphinrc.MainWindow.MenuBar = "Disabled";
      lightlyrc.Style = {
        DolphinSidebarOpacity = 80;
        MenuOpacity = 80;
      };

      powermanagementprofilesrc = let
        events = {
          lidAction = "null";
          powerButtonAction = "null";
        };
      in {
        AC.HandleButtonEvents = events;
        Battery.HandleButtonEvents = events;
        LowBattery.HandleButtonEvents = events;
      };
    };
  };

  # plasma theme
  xdg.dataFile = {
    "plasma/look-and-feel/seaglass".source = ./resources/theme/kde-theme;
  };

  # konsole (make profile file mutable)
  xdg.dataFile."konsole/Pywal.profile".source = config.lib.file.mkOutOfStoreSymlink
    "${builtins.toString ./.}/resources/konsole.profile";
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
