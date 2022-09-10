{ lib, config, pkgs, ... }:

let
  spicetify = fetchTarball https://github.com/cidkidnix/spicetify-nix/archive/1ff091d9c4736f5890d2885ee32defe7a268b908.tar.gz;
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  imports = [
    (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz}/nixos")
  ];
  home-manager.users.alex = { config, options, ... }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };

    imports = [
      ./libs/kde-home-manager.nix
      ./pkgs/hud-menu/service.nix
      ./pkgs/i3-sidebar.nix
      ./i3.nix
      ./terminal.nix
      ./firefox.nix
      ./emacs
      # ./pkgs/spicetify/module.nix
      (import "${spicetify}/module.nix")
    ];

    home.file = {
      ".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
    };

    programs.git = {
      enable = true;
      userName = "alexhulbert";
      userEmail = "alex@alexhulbert.com";
    };

    xdg.configFile."wal/templates/rofi.rasi".source = ./resources/theme/rofi.rasi;
    programs.rofi = {
      enable = true;
      theme = "${config.xdg.cacheHome}/wal/rofi.rasi";
    };

    xdg.dataFile."konsole/Pywal.profile".source = ./resources/konsole.profile;
    xdg.dataFile."kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;

    xdg.configFile."plasma-workspace/env/set-theme.sh".source = pkgs.writeScript "set-wallpaper.sh" ''
      cd /etc/nixos/resources/theme
      ./theme.sh ~/wallpaper/$(ls ~/wallpaper | shuf -n 1)
    '';

    xdg.configFile."plasma-workspace/env/kde-theme.sh".source = pkgs.writeScript "kde-theme.sh" ''
      krunner -d &
      until pidof krunner; do sleep 0.05; done
      lookandfeeltool -a nixos
    '';

    services.picom = {
      enable = true;
      package = pkgs.picom.overrideAttrs(o: {
        src = pkgs.fetchFromGitHub {
          repo = "picom-jonaburg-fix";
          owner = "Arian8j2";
          rev = "31d25da22b44f37cbb9be49fe5c239ef8d00df12";
          sha256 = "0vkf4azs2xr0j03vkmn4z9ll4lw7j8s2k0rdsfw630hd78l1ngnp";
        };
        /*src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "dccsillag";
          rev = "51b21355696add83f39ccdb8dd82ff5009ba0ae5";
          sha256 = "1prwjdwhg4m4alrx1b0r7zd5g9qfx7m12a9d431d1rvwjx2b1c3j";
        };*/
      });
      shadow = true;
      blur = true;
      experimentalBackends = true;
      opacityRule = [
        "88:class_g = 'Code'"
        "88:class_g = 'jetbrains-idea-ce'"
        "88:class_g = 'qBittorrent'"
      ];
      extraOptions = ''
        corner-radius = 20;
        blur-method = "dual_kawase";
        blur-strength = 9;
        xinerama-shadow-crop = true;
        rounded-corners-exclude = [
          "window_type = 'dock'",
          "window_type = 'desktop'"
        ];
      '';
      shadowExclude = [
        "bounding_shaped && !rounded_corners"
      ];
      fade = true;
      fadeDelta = 5;
      vSync = true;
    };

    programs.spicetify = {
      enable = true;
      theme = "Dribbblish";
      colorScheme = "nord-dark";
      # theme = "DribbblishDynamic";
      # colorScheme = "base";
      enabledCustomApps = [ "reddit" ];
      enabledExtensions = [ "newRelease.js" ];
      # spotifyLaunchFlags = " --deviceScaleFactor=2 ";
    };

    programs.vscode = {
      enable = true;
      userSettings = {
        "workbench.colorTheme" = "Wal";
        "breadcrumbs.enabled" = false;
        "editor.minimap.enabled" = false;
        "editor.scrollbar.horizontal" = "hidden";
        "editor.scrollbar.vertical" = "hidden";
        "editor.overviewRulerBorder" = false;
        "editor.hideCursorInOverviewRuler" = true;
        "editor.occurrencesHighlight" = false;
        "editor.inlineSuggest.enabled" = true;
        "vim.handleKeys" = { 
          "<C-k>" = false;
          "<C-a>" = false;
          "<C-t>" = false;
          "<C-g>" = false;
          "<C-f>" = false;
          "<C-c>" = false;
          "<C-v>" = false;
          "<C-x>" = false;
          "<C-o>" = false;
          "<C-n>" = false;
        };
        "vim.enableNeovim" = true;
        "vim.startInInsertMode" = true;
        "editor.fontLigatures" = true;
        "editor.fontFamily" = "FiraCode Nerd Font";
      };
      keybindings = [{
        key = "ctrl+c";
        command = "workbench.action.terminal.copySelection";
        when = "terminalFocus && terminalProcessSupported && terminalTextSelected";
      } {
        key = "ctrl+v";
        command = "workbench.action.terminal.paste";
        when = "terminalFocus";
      }];
    };

    services.unclutter.enable = true;

    programs.kde = {
      enable = true;
      files = [ "konsolerc" "kdeglobals" "ksplashrc" "kwalletrc" ];
      settings = {
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
        kwalletrc.Wallet.Enabled = "false";
      };
    };
  };
}
