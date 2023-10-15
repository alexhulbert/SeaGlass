{
  config,
  pkgs,
  lib,
  ...
}: {
  xdg.configFile.startkderc.text = ''
    [General]
    systemdBoot=false
  '';

  home.file = {
    ".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
  };

  xdg.configFile."plasma-workspace/env/set-theme.sh".source = pkgs.writeScript "set-wallpaper.sh" ''
      cd ${./resources/theme}
      ./theme.sh ~/wallpaper/$(ls ~/wallpaper | shuf -n 1)
  '';

  programs.plasma = {
    shortcuts = {
      "org.kde.dolphin.desktop"."_launch" = [];
      plasmashell = {
        "manage activities" = [];
        "activate task manager entry 1" = ["Alt+1"];
        "activate task manager entry 2" = ["Alt+2"];
        "activate task manager entry 3" = ["Alt+3"];
        "activate task manager entry 4" = ["Alt+4"];
        "activate task manager entry 5" = ["Alt+5"];
        "activate task manager entry 6" = ["Alt+6"];
        "activate task manager entry 7" = ["Alt+7"];
        "activate task manager entry 8" = ["Alt+8"];
        "activate task manager entry 9" = ["Alt+9"];
        "activate task manager entry 10" = ["Alt+0"];
      };
    };
    configFile = {
      kdeglobals = {
        General.BrowserApplication = "firefox.desktop";
      };
      konsolerc = {
        "Desktop Entry" = {
          DefaultProfile = "Pywal.profile";
        };
        MainWindow = {
          MenuBar = "Disabled";
          StatusBar = "Disabled";
          ToolBarsMovable = "Disabled";
          State = "AAAA/wAAAAD9AAAAAAAAB1MAAAjMAAAABAAAAAQAAAAIAAAACPwAAAABAAAAAgAAAAIAAAAWAG0AYQBpAG4AVABvAG8AbABCAGEAcgAAAAAA/////wAAAAAAAAAAAAAAHABzAGUAcwBzAGkAbwBuAFQAbwBvAGwAYgBhAHIAAAAAAP////8AAAAAAAAAAA==";
        };
      };
      ksplashrc = {
        KSplash = {
          Engine = "None";
          Theme = "None";
        };
      };
      # startkderc.General.systemdBoot = false;
      kdeglobals.General = {
        fixed = "FiraCode Nerd Font,11,-1,5,50,0,0,0,0,0";
        font = "SFNS Display,11,-1,5,50,0,0,0,0,0";
        menuFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
        smallestReadableFont = "SFNS Display,9,-1,5,50,0,0,0,0,0";
        toolBarFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
      };
      kcminputrc.Mouse = {
        cursorSize = 56;
        X11LibInputXAccelProfileFlat = true;
        XLbInptAccelProfileFlat = true;
        XLbInptPointerAcceleration = 1;
      };
      kwalletrc.Wallet.Enabled = "false";
      dolphinrc.MainWindow.MenuBar = "Disabled";
      lightlyrc.Style.DolphinSidebarOpacity = 80;
      kscreenlockerrc.Daemon = {
        Autolock = false;
        LockOnResume = false;
      };
      ksmserverrc.General.loginMode = "emptySession";
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      plasmahudrc = {
        General = {
          Matching = "fuzzy";
          Width = 100;
        };
        Icons.Enabled = false;
        Style = {
          Title = "Menu";
          Font = "FiraCode Nerd Font 13";
        };
      };
    };
  };
}
