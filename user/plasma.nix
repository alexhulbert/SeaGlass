{
  config,
  pkgs,
  lib,
  ...
}: let
  papirus-icons = import ./pkgs/papirus-icons.nix {inherit pkgs;};
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

  outOfStoreSymlinks.home = {
    ".local/bin/seaglass-spicetify" = "${builtins.toString ./.}/files/theme/seaglass-spicetify.py";
    ".local/bin/seaglass-theme" = "${builtins.toString ./.}/files/theme/seaglass-theme.sh";
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
          widgetStyle = "Darkly";
        };
      };
      dolphinrc.MainWindow.MenuBar = "Disabled";
      darklyrc.Style = {
        DolphinSidebarOpacity = 80;
        MenuOpacity = 80;
      };

      powermanagementprofilesrc = let
        events = grp: {
          lidAction = "null";
          powerButtonAction = "null";
          configGroupNesting = [grp "HandleButtonEvents"];
        };
      in {
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
          sidebar_config = 0;
          home_config = 1;
          experimental_fesatures = 1;
        };
      };

      "zoomus.conf".General.xwayland = false;

      "mimeapps.list"."Default Applications" = {
        # Images - Gwenview
        "image/png" = "org.kde.gwenview.desktop";
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/gif" = "org.kde.gwenview.desktop";
        "image/webp" = "org.kde.gwenview.desktop";
        "image/svg+xml" = "org.kde.gwenview.desktop";
        "image/bmp" = "org.kde.gwenview.desktop";
        "image/tiff" = "org.kde.gwenview.desktop";

        # Documents - GNOME Papers
        "application/pdf" = "org.gnome.Papers.desktop";
        "application/epub+zip" = "org.gnome.Papers.desktop";
        "application/x-cbz" = "org.gnome.Papers.desktop";
        "application/x-cbr" = "org.gnome.Papers.desktop";
        "image/vnd.djvu" = "org.gnome.Papers.desktop";

        # Text - KWrite
        "text/plain" = "org.kde.kwrite.desktop";
        "text/markdown" = "org.kde.kwrite.desktop";
        "text/csv" = "org.kde.kwrite.desktop";
        "application/json" = "org.kde.kwrite.desktop";
        "application/xml" = "org.kde.kwrite.desktop";
        "text/xml" = "org.kde.kwrite.desktop";
      };
    };
  };

  outOfStoreSymlinks.xdgConfig."spicetify/Themes/Ziro" = "/opt/spicetify-cli/Themes/Ziro";

  # Plasma theme
  outOfStoreSymlinks.xdgData."plasma/look-and-feel/seaglass" = "${builtins.toString ./.}/files/theme/kde-theme";

  # Icons
  xdg.dataFile."icons/Papirus-Colors".source = "${papirus-icons}/Papirus-Colors";
  xdg.dataFile."icons/Papirus-Colors-Dark".source = "${papirus-icons}/Papirus-Colors-Dark";

  xdg.configFile."wal/templates/primenote.css".source = ./files/theme/primenote.css;

  # Fonts
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "SF Pro Display"
        "SFNS Display"
        "Source Han Sans"
        "Source Han Sans SC"
        "Source Han Sans TC"
        "Source Han Sans JP"
        "Source Han Sans K"
      ];
      monospace = [
        "FiraCode Nerd Font"
        "Source Han Mono"
      ];
      serif = [
        "New York"
        "Source Han Serif"
        "Source Han Serif SC"
        "Source Han Serif TC"
        "Source Han Serif JP"
        "Source Han Serif K"
      ];
      /*
        emoji = [
        "Apple Color Emoji"
      ];
      */
    };
  };
}
