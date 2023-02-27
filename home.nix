{ lib, config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  home-manager = builtins.fetchTarball {
    url = https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz;
    sha256 = "sha256:0vg6x7cw2bpiga9k6nlj2n1vrm4qw84721gmlhp3j1i58v100ybc";
  };
  /*home-manager = builtins.fetchTarball {
    url = https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz;
    sha256 = "sha256:0n0pqfjprs14phshidma84pn1ny8ibaz8agrwm9dr9abcg5f6vbr";
  };*/
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  spicetify-nix = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/the-argus/spicetify-nix/archive/master.tar.gz";
  }).defaultNix;
  plasma-manager = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/master.tar.gz";
  }).defaultNix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
  vscodeTheme = builtins.fromJSON (builtins.readFile "/home/alex/.vscode/extensions/swashata.beautiful-ui-1.7.0/themes/Tomorrow Subliminal-color-theme.json");
in {
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.alex = { config, options, ... }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
    imports = [
      ./pkgs/i3-sidebar.nix
      ./i3.nix
      ./terminal.nix
      ./firefox.nix
      ./emacs
      spicetify-nix.homeManagerModule
      plasma-manager.homeManagerModules.plasma-manager
    ];

    home.file = {
      ".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
    };

    programs.git = {
      enable = true;
      userName = "alexhulbert";
      userEmail = "alex@alexhulbert.com";
    };

    xdg.configFile."wal/templates/hud.rasi".source = ./resources/theme/hud.rasi;
    xdg.configFile."wal/templates/rofi.rasi".source = ./resources/theme/rofi.rasi;
    programs.rofi = {
      enable = true;
      theme = "${config.xdg.cacheHome}/wal/hud.rasi";
    };

    xdg.dataFile."konsole/Pywal.profile".source = ./resources/konsole.profile;
    xdg.dataFile."kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;

    xdg.configFile."plasma-workspace/env/x-fwd.sh".source = pkgs.writeScript "x-fwd.sh" ''
      ${pkgs.xorg.xhost}/bin/xhost +si:localuser:$USER
    '';

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
        /*src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "yshui";
          rev = "f2970bc697bdf20d398d1be05ff72d50df911e64";
          sha256 = "1hvpd51aq5fg71a48ln0bd7sm6bh5gi4vrfy8pjgyhi3mhq1gq39";
        };*/
        /*src = pkgs.fetchFromGitHub {
          repo = "picom-jonaburg-fix";
          owner = "Arian8j2";
          rev = "31d25da22b44f37cbb9be49fe5c239ef8d00df12";
          sha256 = "0vkf4azs2xr0j03vkmn4z9ll4lw7j8s2k0rdsfw630hd78l1ngnp";
        };*/
        /*src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "dccsillag";
          rev = "51b21355696add83f39ccdb8dd82ff5009ba0ae5";
          sha256 = "1prwjdwhg4m4alrx1b0r7zd5g9qfx7m12a9d431d1rvwjx2b1c3j";
        };*/
        /*src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "FT-Labs";
          rev = "f6b0b04f5bd8bc5f727cc3bb17802a88ca87ed51";
          sha256 = "sha256-XbozDrOoTVYZDgwzNoUi6+LVbvrdDe8LEnyDioLZuq0=";
        };*/
        src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "traidento";
          rev = "d45a3081a0774a869dbd83c9192454d6561a51ec";
          sha256 = "sha256-LZ8gLb52jJk2frrcmvbJws9DGRL+UZZ2AnXR3B3ePuM=";
        };
      });
      shadow = true;
      blur = true;
      opacityRule = [
        "88:class_g = 'Code'"
        "88:class_g = 'jetbrains-idea-ce'"
        "88:class_g = 'qBittorrent'"
        "88:class_g = 'Spotify'"
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

        animations = true;
        animation-stiffness = 200;

        # animation-window-mass = 0.4;
        # animation-dampening = 15;
        # animation-clamping = true;
      '';
      shadowExclude = [
        "bounding_shaped && !rounded_corners"
      ];
      fade = true;
      fadeDelta = 5;
      vSync = true;
    };

    programs.spicetify = let
      nordTheme = pkgs.fetchgit {
        url = "https://github.com/Tetrax-10/Nord-Spotify";
        rev = "6a26e9928fbb044577c8fd2f6d61ac04e4cedc3b";
        sha256 = "sha256-ABbOXHZUKUCYn4Qp0RIPstJ8ruO/LoqRzhG4Sh8OuhA=";
      };
      tetraxSrc = pkgs.fetchgit {
        url = "https://github.com/Tetrax-10/Spicetify-Extensions";
        rev = "7e0e909d83db7a11889032a87c15c7cc539cff60";
        sha256 = "sha256-DPETej0UmC6+yyqQNnDYfSR+7deoRZjs3Dop8E5crqM=";
      };
      songRating = pkgs.fetchgit {
        url = "https://github.com/duffey/spotify-star-ratings";
        rev = "51ce96d2a3c9b2ec07aeb87c7e1ac67c85a797b7";
        sha256 = "sha256-NSuDoNuzopVaEqABhA15GPJ5O6HH7Sbo5CNf0+en8uc=";
      };
    in {
      enable = true;
      spotifyPackage = unstable.spotify-unwrapped;
      spicetifyPackage = unstable.spicetify-cli;
      theme = {
        name = "Nord-Spotify";
        src = nordTheme;
        requiredExtensions = [{
          filename = "injectNord.js";
          src = "${nordTheme}/src";
        }];
        appendName = true;
        injectCss = true;
        overwriteAssets = true;
        replaceColors = true;
        sidebarConfig = false;
      };
      colorScheme = "Spotify";
      enabledCustomApps = with spicePkgs.apps; [
        reddit
        localFiles
      ];
      enabledExtensions = with spicePkgs.extensions; [
        groupSession
        featureShuffle
        copyToClipboard
        history
        playNext
        playlistIntersection
        # skipOrPlayLikedSongs
        {
          src = "${songRating}";
          filename = "starRatings.js";
        }
        {
          src = "${tetraxSrc}/Spotify-Genres";
          filename = "spotifyGenres.js";
        }
        {
          src = "${tetraxSrc}/Play-Enhanced-Songs";
          filename = "playEnhancedSongs.js";
        }
        {
          src = "${tetraxSrc}/Sort-by-Rating";
          filename = "sortByRating.js";
        }
      ];
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
        "editor.tokenColorCustomizations" = {
          "textMateRules" = vscodeTheme.tokenColors;
        };
      };
      keybindings = [{
        key = "ctrl+c";
        command = "workbench.action.terminal.copySelection";
        when = "terminalFocus && terminalProcessSupported && terminalTextSelected";
      } {
        key = "ctrl+v";
        command = "workbench.action.terminal.paste";
        when = "terminalFocus";
      } {
        key = "shift shift";
        command = "workbench.action.quickOpen";
      } {
        key = "ctrl ctrl";
        command = "workbench.action.showCommands";
      }];
    };

    services.unclutter.enable = true;

    programs.plasma = {
      shortcuts = {
        plasmashell = {
          "manage activities" = [];
          "activate task manager entry 1" = "Alt+1";
          "activate task manager entry 2" = "Alt+2";
          "activate task manager entry 3" = "Alt+3";
          "activate task manager entry 4" = "Alt+4";
          "activate task manager entry 5" = "Alt+5";
          "activate task manager entry 6" = "Alt+6";
          "activate task manager entry 7" = "Alt+7";
          "activate task manager entry 8" = "Alt+8";
          "activate task manager entry 9" = "Alt+9";
          "activate task manager entry 10" = "Alt+0";
        };
      };
      files = {
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

    systemd.user.services.plasma-hud = {
      Service = {
        ExecStart = "${pkgs.callPackage ./pkgs/plasma-hud.nix {}}/bin/plasma-hud";
        Restart = "always";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        After = [ "graphical-session-pre.target" ];
        Description = "Plasma HUD";
        PartOf = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.rdp = {
      Service = {
        ExecStart = "${pkgs.distrobox}/bin/distrobox enter -r arch -- cassowary -bc";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Unit = {
        Description = "Cassowary Background Client";
        # PartOf = [ "graphical-session.target" ];
        Wants = [ "plasma-kcminit.service" ];
      };
    };
  };
}
