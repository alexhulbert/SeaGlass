{
  lib,
  config,
  pkgs,
  ...
}: let
  unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
  home-manager = builtins.fetchTarball {
    url = https://github.com/nix-community/home-manager/archive/master.tar.gz;
    # sha256 = "sha256:0jgl1cp4qafga1ns6w7yqdccla0mg7s69rkjw4qkkpfjbkidh085";
    sha256 = "sha256:0c2zjrfmpdhv7r2v61p1z34r6j8gkmh6wzara1k5kmm2rak0sdvi";
  };
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  spicetify-nix =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/the-argus/spicetify-nix/archive/master.tar.gz";
    })
    .defaultNix;
  plasma-manager =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/master.tar.gz";
    })
    .defaultNix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
  vscodeTheme = builtins.fromJSON (builtins.readFile "/home/alex/.vscode/extensions/swashata.beautiful-ui-1.7.0/themes/Tomorrow Subliminal-color-theme.json");
in {
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.alex = {
    config,
    options,
    ...
  }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
    imports = [
      ./pkgs/i3-sidebar.nix
      ./pkgs/i3-alternating-layouts.nix
      ./i3.nix
      ./terminal.nix
      ./firefox.nix
      ./vim
      spicetify-nix.homeManagerModule
      plasma-manager.homeManagerModules.plasma-manager
    ];

    home.file = {
      ".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
    };
    home.stateVersion = "22.11";

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

    xdg.configFile."wal/templates/picom-chromakey.glsl".source = ./resources/theme/picom-chromakey.glsl;
    services.picom = {
      enable = true;
      package = pkgs.picom.overrideAttrs (o: {
        buildInputs = o.buildInputs ++ [pkgs.pcre2];
        /*
          src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "yshui";
          rev = "f2970bc697bdf20d398d1be05ff72d50df911e64";
          sha256 = "1hvpd51aq5fg71a48ln0bd7sm6bh5gi4vrfy8pjgyhi3mhq1gq39";
        };
        */
        /*
          src = pkgs.fetchFromGitHub {
          repo = "picom-jonaburg-fix";
          owner = "Arian8j2";
          rev = "31d25da22b44f37cbb9be49fe5c239ef8d00df12";
          sha256 = "0vkf4azs2xr0j03vkmn4z9ll4lw7j8s2k0rdsfw630hd78l1ngnp";
        };
        */
        /*
          src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "alexhulbert";
          rev = "131b06f0204e603085736e77fe628073d3a285cb";
          sha256 = "sha256-xPcHqtyo3I6jf+isJWE6HXLaK36i7PzgdgrZDPOhTLs=";
        };
        */
        /*
          src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "dccsillag";
          rev = "51b21355696add83f39ccdb8dd82ff5009ba0ae5";
          sha256 = "1prwjdwhg4m4alrx1b0r7zd5g9qfx7m12a9d431d1rvwjx2b1c3j";
        };
        */

        src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "FT-Labs";
          rev = "dc9d1fe2481e7de1a52b0ff98b4253a4f5da0493";
          sha256 = "sha256-hDuL5g5+l0IUqq6jYdVXDtaTbheuLPzo/SaUY+WtoH8=";
        };

        /*
          src = pkgs.fetchFromGitHub {
          repo = "picom";
          owner = "traidento";
          rev = "d45a3081a0774a869dbd83c9192454d6561a51ec";
          sha256 = "sha256-LZ8gLb52jJk2frrcmvbJws9DGRL+UZZ2AnXR3B3ePuM=";
        };
        */
      });
      shadow = true;
      activeOpacity = 0.99;
      inactiveOpacity = 0.99;
      wintypes = {
        utility = {animations = "none";};
      };
      opacityRules = [
        "88:class_g = 'Spotify'"
      ];
      settings = {
        corner-radius = 20;
        backend = "glx";
        blur-background = true;
        blur-method = "dual_kawase";
        blur-strength = 15;
        xinerama-shadow-crop = true;

        unredir-if-possible = true;
        no-ewmh-fullscreen = true;
        window-shader-fg-rule = [
          (lib.strings.concatStrings [
            "${config.xdg.cacheHome}/wal/picom-chromakey.glsl:"
            "_NET_WM_STATE@[0]:32a != '_NET_WM_STATE_FULLSCREEN' && "
            "_NET_WM_STATE@[1]:32a != '_NET_WM_STATE_FULLSCREEN' && "
            "_NET_WM_STATE@[2]:32a != '_NET_WM_STATE_FULLSCREEN' && "
            "_NET_WM_STATE@[3]:32a != '_NET_WM_STATE_FULLSCREEN' && "
            "_NET_WM_STATE@[4]:32a != '_NET_WM_STATE_FULLSCREEN' && "
            "class_g != 'albert'"
          ])
        ];

        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
        ];

        animations = false;
        animation-stiffness-in-tag = 200;
        animation-stiffness-tag-change = 200;

        animation-window-mass = 0.4;
        # animation-dampening = 15;
        # animation-clamping = true;

        transition = true;
      };
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
        rev = "17acc0479df75231f1e81f740ed199138d7bbda3";
        sha256 = "sha256-YW/8uQsc4vt7E3EeSKZRWUMaG3X8cfsTMB186FyQ0cE=";
      };
      tetraxSrc = pkgs.fetchgit {
        url = "https://github.com/Tetrax-10/Spicetify-Extensions";
        rev = "bea1698eaa5a8ce32572452cc1c6b9fc6a9d39de";
        sha256 = "sha256-O1yueXldU862Efh1T5ZonjZ2Y5triv60eJgCqeAaBSc=";
      };
      songRating = pkgs.fetchgit {
        url = "https://github.com/duffey/spotify-star-ratings";
        rev = "8a9843e7a2a7414e3a9c18e6b5203f6715da8eec";
        sha256 = "sha256-y/eQxcOJbQPAdOPJYXML7QxKl4BX3RERDgOvqDk3ayg=";
      };
    in {
      enable = true;
      extraCommands = "enable-devtool";
      spotifyPackage = pkgs.spotify-unwrapped;
      spicetifyPackage = pkgs.spicetify-cli;
      theme = {
        name = "Nord";
        src = nordTheme;
        requiredExtensions = [
          #{
          #  filename = "injectNord.js";
          #  src = "${nordTheme}/src";
          #}
        ];
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
      /*userSettings = {
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
        "arduino.additionalUrls" = [
          "https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json"
        ];
        "arduino.useArduinoCli" = true;

        "mergetool.keepTemporaries" = false;
        "mergetool.keepBackup" = false;
        "mergetool.code.cmd" = "node \"$BASE\"";
        "merge.tool" = "code";
        "merge.conflictstyle" = "merge";
        "diffEditor.codeLens" = true;
      };*/
      keybindings = [
        {
          key = "ctrl+c";
          command = "workbench.action.terminal.copySelection";
          when = "terminalFocus && terminalProcessSupported && terminalTextSelected";
        }
        {
          key = "ctrl+v";
          command = "workbench.action.terminal.paste";
          when = "terminalFocus";
        }
        {
          key = "shift shift";
          command = "workbench.action.quickOpen";
        }
        {
          key = "ctrl ctrl";
          command = "workbench.action.showCommands";
        }
      ];
    };

    services.unclutter.enable = true;

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
        plasmahudrc = {
          General = {
            Matching = "fuzzy";
            Width = 100;
          };
          Icons.Enabled = false;
          Style = {
            Title = "Menu";
            Font = "FiraCode Nerd Font 22";
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
        WantedBy = ["graphical-session.target"];
      };
      Unit = {
        After = ["graphical-session-pre.target"];
        Description = "Plasma HUD";
        PartOf = ["graphical-session.target"];
      };
    };

    systemd.user.services.albert = {
      Service = {
        ExecStart = "${pkgs.albert}/bin/albert";
        Restart = "always";
        RestartSec = 3;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Unit = {
        Description = "Albert";
        PartOf = ["graphical-session.target"];
        After = ["i3.service"];
      };
    };

    /*systemd.user.services.rdp = {
      Service = {
        ExecStart = "${pkgs.distrobox}/bin/distrobox enter -r arch -- cassowary -bc";
        Restart = "on-failure";
        Slice = "session.slice";
      };
      Unit = {
        Description = "Cassowary Background Client";
        # PartOf = [ "graphical-session.target" ];
        Wants = ["plasma-kcminit.service"];
      };
    };*/
  };
}
