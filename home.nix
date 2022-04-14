{ lib, config, pkgs, ... }:

let
  spicetify = fetchTarball https://github.com/alexhulbert/spicetify-nix/archive/././master.tar.gz;
  pinned-firefox = import (builtins.fetchTarball {
   name = "pinned-firefox-nixpkgs";
    url = "https://github.com/nixos/nixpkgs/archive/657b329f83519c9205a0f41f6a266890e291d7a1.tar.gz";
    sha256 = "1gj0mysd6q461ny13cpdclnvqh7f11zrzyr83234mi6vkjw5vdqw";
  }) {};
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
      # ./emacs
      # ./pkgs/spicetify/module.nix
    ];
    home.file = {
      ".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
        "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
      ".mozilla/native-messaging-hosts/darkreader.json".text = builtins.toJSON {
        name = "darkreader";
        description = "custom darkreader native host for syncing with pywal";
        path = "/etc/nixos/resources/darkreader/index.js";
        type = "stdio";
        allowed_extensions = [ "darkreader@alexhulbert.com" ];
      };
      ".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
    };

    programs.git = {
      enable = true;
      userName = "alexhulbert";
      userEmail = "alex@alexhulbert.com";
    };
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        bars = [];
        gaps = {
          inner = 15;
          outer = 0;
        };
        modifier = "Mod4";
        terminal = "konsole";
        keycodebindings = {
          "66" = "workspace back_and_forth";
          "control+66" = "exec --no-startup-id xdotool key Caps_Lock";
        };
        keybindings = let modifier = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
          "${modifier}+control+shift+q" = "exec --no-startup-id xdotool getwindowfocus windowkill";
          "${modifier}+e" = "exec --no-startup-id hud-menu";
          "${modifier}+d" = "exec --no-startup-id \"sh -c 'SESSION_MANAGER= krunner; sleep 0.1; i3-msg [class=krunner] move absolute position 1320 0'\"";
          "${modifier}+shift+a" = "exec --no-startup-id \"i3-sidebar Todoist left 0.3 'firefox -P ssb --new-window https://todoist.com'\"";
          "${modifier}+shift+s" = "exec --no-startup-id \"i3-sidebar Spotify top 0.66 spotify\"";
          "${modifier}+shift+d" = "exec --no-startup-id \"i3-sidebar Messenger right 0.4 'firefox -P ssb --new-window https://messenger.com'\"";
          "${modifier}+shift+w" = "exec --no-startup-id \"i3-sidebar Konsole top 0.4 konsole\"";

        };
      };
      extraConfig = ''
        for_window [class="^.*"] border pixel 0
        for_window [title="Desktop — Plasma"] kill; floating enable; border none
        for_window [title="win0"] floating enable
        for_window [title="Picture-in-Picture"] sticky enable
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="task_dialog"] floating enable
        for_window [class="plasmashell"] floating enable
        for_window [class="Plasma"] floating enable; border none
        for_window [title="plasma-desktop"] floating enable; border none
        for_window [class="krunner"] floating enable; border none
        for_window [class="Plasmoidviewer"] floating enable; border none
        for_window [class="plasmashell" window_type="notification"] border none, move right 1400px, move down 900px
        no_focus [class="plasmashell" window_type="notification"]
	      exec --no-startup-id i3-msg workspace 1
      '';
    };

    home.sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
    };

    programs.rofi.theme = ./resources/launchpad.rasi;

    home.packages = [
      (
        pkgs.writeTextFile {
          name = "hm-session-vars.sh";
          destination = "/etc/profile.d/hm-session-vars-2.sh";
          text = ''
            ${config.lib.shell.exportAll config.home.sessionVariables}
          '' + lib.optionalString (config.home.sessionPath != [ ]) ''
            export PATH="$PATH''${PATH:+:}${pkgs.builtins.concatStringsSep ":" config.home.sessionPath}"
          '' + config.home.sessionVariablesExtra;
        }
      )
    ];

    xdg.dataFile."konsole/Pywal.profile".source = ./resources/konsole.profile;
    xdg.dataFile."kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;

    xdg.configFile."plasma-workspace/env/set-theme.sh".source = pkgs.writeScript "set-wallpaper.sh" ''
      cd /etc/nixos/resources/theme
      ./theme.sh ~/wallpaper/$(ls ~/wallpaper | shuf -n 1)
    '';

    xdg.configFile."plasma-workspace/env/kde-theme.sh".source = pkgs.writeScript "kde-theme.sh" ''
      (sleep 10; lookandfeeltool -a nixos) &
    '';

    xdg.configFile."fish/conf.d/hm-session-vars.fish".text = ''
      set --prepend fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars-2.sh > /dev/null
      set -e fish_function_path[1]
    '';

    xdg.configFile."fish/conf.d/theme.fish".text = ''
      # fenv source ${config.home.homeDirectory}/.cache/wal/colors-tty.sh
      cat ${config.home.homeDirectory}/.cache/wal/sequences &
      source ${config.home.homeDirectory}/.cache/wal/pywal.fish
    '';

    xdg.configFile."fish/conf.d/any-nix-shell.fish".text = ''
      any-nix-shell fish --info-right | source
    '';

    xdg.configFile."wal/templates/pywal.fish".source = ./resources/theme/pywal.fish;

    services.picom = {
      enable = true;
      package = pkgs.picom.overrideAttrs(o: {
        src = pkgs.fetchFromGitHub {
          repo = "picom-jonaburg-fix";
          owner = "Arian8j2";
          rev = "31d25da22b44f37cbb9be49fe5c239ef8d00df12";
          sha256 = "0vkf4azs2xr0j03vkmn4z9ll4lw7j8s2k0rdsfw630hd78l1ngnp";
        };
      });
      shadow = true;
      blur = true;
      experimentalBackends = true;
      opacityRule = [
        "92:class_g = 'Code'"
        "92:class_g = 'jetbrains-idea-ce'"
        "92:class_g = 'qBittorrent'"
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

    /*programs.spicetify = {
      enable = true;
      theme = "Dribbblish";
      colorScheme = "nord-dark";
      enabledCustomApps = ["reddit"];
      enabledExtensions = ["newRelease.js"];
      # spotifyLaunchFlags = " --deviceScaleFactor=2 ";
    };*/

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
        "vim.handleKeys" = { 
          "<C-k>" = false;
          "<C-a>" = false;
          "<C-t>" = false;
          "<C-g>" = false;
          "<C-f>" = false;
          "<C-c>" = false;
          "<C-v>" = false;
          "<C-x>" = false;
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

    programs.fish = {
      enable = true;
      shellAliases = {
        start = "sudo systemctl start";
        stop = "sudo systemctl stop";
        restart = "sudo systemctl restart";
        slog = "sudo systemctl status";
        log = "sudo journalctl";

        ustart = "systemctl start --user";
        ustop = "systemctl stop --user";
        urestart = "systemctl restart --user";
        uslog = "systemctl status --user";
        ulog = "journalctl --user";

        e = "nvim";
        se = "sudo nvim";
        
        ls = "exa";
        cat = "bat";

        sw = "sudo nixos-rebuild switch";
        nix-repl = "nix repl '<nixpkgs>' '<nixpkgs/nixos>'";
        
        ldm = "sudo systemctl restart display-manager";

        radix-up = "sudo docker start radix 2>&1 > /dev/null || sudo docker run --privileged --network host -v /home/alex/.ssh:/home/alex/.ssh -v /root/.docker/config.json:/root/.docker/config.json -v /opt/bazel:/opt/bazel -v /opt/radix:/opt/radix -v /home/alex/monorepo:/home/alex/monorepo -v /home/alex/.cache/bazel:/home/alex/.cache/bazel -td --name radix timberland";
        radix-down = "sudo docker stop radix";
        radix-remove = "radix-down 2>&1 > /dev/null; sudo docker rm radix";
        rdx = "sudo docker exec -w (printf / && pwd | grep -Eo \"(home/alex/monorepo|opt/radix).*\\$\") -it radix";
        razel = "rdx sudo -u alex bazel";
      };
      shellInit = ''
        set fish_greeting
        bind \cH backward-kill-word
        bind \e\[3\;5~ kill-word
        bind \e\[5C forward-word
        bind \e\[5D backward-word 
      '';
      plugins = [{
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "a3c55307dce38c73485eac1f654c8f392341bda2";
          sha256 = "0k6l21j192hrhy95092dm8029p52aakvzis7jiw48wnbckyidi6v";
        };
      } {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "fzf";
          rev = "479fa67d7439b23095e01b64987ae79a91a4e283";
          sha256 = "0k6l21j192hrhy95092dm8029p52aakvzis7jiw48wnbckyidi6v";
        };
      } {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "45a9ff6d0932b0e9835cbeb60b9794ba706eef10";
          sha256 = "1kjyl4gx26q8175wcizvsm0jwhppd00rixdcr1p7gifw6s308sd5";
        };
      } {
        name = "hydro";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "hydro";
          rev = "a5877e9ef76b3e915c06143630bffc5ddeaba2a1";
          sha256 = "1lgknykah265wxx6wyy5pqc3w3jhkr2nnybwb4954nlklr12g7ww";
        };
      }];
    };

    programs.starship = {
      enable = true;
      settings = {
        character = {
          success_symbol = "[‍](bold)";
          error_symbol = "[‍](bold)";
        };
        format = "$character";
        right_format = "$all";
        add_newline = false;
        line_break.disabled = true;
        package.disabled = true;
        git_status = {
          untracked = "";
          stashed = "";
          modified = "";
          staged = "";
          renamed = "";
          deleted = "";
        };
        terraform.symbol = " ";
        git_branch.symbol = " ";
        directory.read_only = " ";
        rust = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        scala = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        nix_shell = {
          format = "[$symbol$name ]($style)";
          symbol = " ";
        };
        nodejs = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        golang = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        java = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        deno = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        lua = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        docker_context = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        python = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
      };
    };

    services.unclutter.enable = true;
    
    programs.firefox = {
      enable = true;
      package = pinned-firefox.firefox-esr-91-unwrapped;
      profiles.default = {
        id = 0;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "layers.acceleration.force-enabled" = true;
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "dom.w3c_touch_events.enabled" = 1;
        };
        userChrome = ''
          @import url('blurredfox/userChrome.css');
          @import url('userContent.css');
          @import url('oneline.css');
        '';
      };
      profiles.ssb = {
        id = 1;
        settings = config.programs.firefox.profiles.default.settings;
        userChrome = ''
          @import url('blurredfox/userChrome.css');
          @import url('userContent.css');
          @import url('nochrome.css');
        '';
      };
    };

    home.file.".mozilla/firefox/default/chrome/blurredfox".source = pkgs.fetchFromGitHub {
      owner = "manilarome";
      repo = "blurredfox";
      rev = "6976b5460f47bd28b4dc53bd093012780e6bfed3";
      sha256 = "0mj47pv27dv2bk4hsdjl3c81kw6bz9kk7gkdz30l4z88ckj31j0j";
    };

    home.file.".mozilla/firefox/default/chrome/oneline.css".source = ./resources/theme/oneline.css;

    home.file.".mozilla/firefox/default/chrome/blur.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pavlukivan/dotfiles/6dfa74974cb25d9730a37bf4895a0f8421092b9e/firefox-transparency.css";
      sha256 = "0k1h14hpzm25sh7jrrxrgafrhld742gy0ybf74fz1n7s8w0fd1kn";
    };

    home.file.".mozilla/firefox/ssb/chrome/nochrome.css".source = ./resources/theme/nochrome.css;
    home.file.".mozilla/firefox/ssb/chrome/blurredfox" = {
      source = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/blurredfox";
      recursive = true;
    };
    home.file.".mozilla/firefox/ssb/chrome/blur.css" = {
      source = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/blur.css";
      recursive = true;
    };
    home.file.".mozilla/firefox/ssb/chrome/userContent.css" = {
      source = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/userContent.css";
      recursive = true;
    };

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
