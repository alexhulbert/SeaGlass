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
