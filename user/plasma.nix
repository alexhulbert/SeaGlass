{ config
, pkgs
, lib
, ...
}:
let
  papirus-icons = import ./pkgs/papirus-icons.nix { inherit pkgs; };
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  plasma-manager =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/9bac5925cf7716979535eed9c88e307fa9744169.tar.gz";
    }).defaultNix;
in
{
  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  outOfStoreSymlinks.home = {
    ".local/bin/seaglass-spicetify" = "${builtins.toString ./.}/resources/theme/seaglass-spicetify.py";
    ".local/bin/seaglass-theme" = "${builtins.toString ./.}/resources/theme/seaglass-theme.sh";
  };

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

      powermanagementprofilesrc =
        let
          events = grp: {
            lidAction = "null";
            powerButtonAction = "null";
            configGroupNesting = [ grp "HandleButtonEvents" ];
          };
        in
        {
          AC = events "AC";
          Battery = events "Battery";
          LowBattery = events "LowBattery";
        };


      "spicetify/config-xpui.ini" = {
        Setting = {
          spotify_launch_flags = "--enable-features=UseOzonePlatform|--ozone-platform=wayland";
          inject_css = 1;
          inject_theme_js = 1;
          color_scheme = "pywal";
          current_theme = "Ziro";
          replace_colors = 1;
          overwrite_assets = 1;
        };
        AdditionalOptions = {
          custom_apps = "marketplace|stats";
          sidebar_config = 1;
          home_config = 1;
          experimental_fesatures = 1;
        };
      };

      "zoomus.conf".General.xwayland = false;
    };
  };

  # Plasma theme
  outOfStoreSymlinks.xdgData."plasma/look-and-feel/seaglass" = "${builtins.toString ./.}/resources/theme/kde-theme";

  # Icons
  xdg.dataFile."icons/Papirus-Colors".source = "${papirus-icons}/Papirus-Colors";
  xdg.dataFile."icons/Papirus-Colors-Dark".source = "${papirus-icons}/Papirus-Colors-Dark";
}
