{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  plasma-manager =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/9bac5925cf7716979535eed9c88e307fa9744169.tar.gz";
    })
    .defaultNix;
in {
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  home.file.".local/bin/seaglass-theme".source = config.lib.file.mkOutOfStoreSymlink
    "${builtins.toString ./.}/resources/theme/seaglass-theme.sh";

  programs.plasma = {
    enable = true;
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
        events = grp: {
          lidAction = "null";
          powerButtonAction = "null";
          configGroupNesting = [ grp "HandleButtonEvents" ];
        };
      in {
        AC = events "AC";
        Battery = events "Battery";
        LowBattery = events "LowBattery";
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
