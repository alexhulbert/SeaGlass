{ lib, config, pkgs, ... }:

let
  buildFirefoxXpiAddon = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon;
in {
  imports = [
    (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz}/nixos")
  ];
  home-manager.users.alex = { config, ... }: {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };

    imports = [
      ./libs/kde-home-manager.nix
    ];
    home.file = {
      ".local/share/kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;
      ".mozilla/native-messaging-hosts/pywalfox.json".source = ./resources/pywalfox.json;
      #".local/share/plasma/look-and-feel/nixos".source = ./resources/theme/kde-theme;
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
        # i3-hud-menu
      };
      extraConfig = ''
        for_window [title="Desktop — Plasma"] kill; floating enable; border none
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="task_dialog"] floating enable
        for_window [class="plasmashell"] floating enable
        for_window [class="Plasma"] floating enable; border none
        for_window [title="plasma-desktop"] floating enable; border none
        for_window [class="krunner"] floating enable; border none
        for_window [class="Plasmoidviewer"] floating enable; border none
        for_window [class="plasmashell" window_type="notification"] border none, move right 700px, move down 450px
        no_focus [class="plasmashell" window_type="notification"]
      '';
    };

    home.sessionVariables = {
      FZF_COMPLETE = "2";
      FZF_DISABLE_KEYBINDINGS = "1";
      FZF_LEGACY_KEYBINDINGS = "0";
      FZF_TMUX = "1";
    };

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

    xdg.configFile."fish/conf.d/hm-session-vars.fish".text = ''
      set --prepend fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars-2.sh > /dev/null
      set -e fish_function_path[1]
    '';

    xdg.configFile."fish/conf.d/theme.fish".text = ''
      # fenv source ${config.home.homeDirectory}/.cache/wal/colors-tty.sh
      cat ${config.home.homeDirectory}/.cache/wal/sequences &
    '';

    xdg.configFile."fish/conf.d/any-nix-shell.fish".text = ''
      any-nix-shell fish --info-right | source
    '';

    programs.firefox = {
      enable = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        plasma-integration
        https-everywhere
        lastpass-password-manager
        vimium
        greasemonkey
        unpaywall
        zoom-redirector
        (buildFirefoxXpiAddon {
          pname = "pywalfox";
          addonId = "pywalfox@frewacom.org";
          version = "2.0.7";
          url = "https://addons.mozilla.org/firefox/downloads/file/3789954/pywalfox-2.0.7-fx.xpi";
          sha256 = "1ga1f3g5zgf0i06jjah8jyjmxifpdx1zb0n28cdijlxzlip09kdf";
          meta = {};
        })
        (buildFirefoxXpiAddon {
          pname = "youtube-smart-tv";
          addonId = "{d2bcedce-889b-4d53-8ce9-493d8f78612a}";
          version = "0.0.3";
          url = "https://addons.mozilla.org/firefox/downloads/file/3420768/youtubetm_for_tv-0.0.3-fx.xpi";
          sha256 = "1ajgl61jrx64m2iqqs729i9f1pa7s7wgfwhygfgqrl033rqbpxjx";
          meta = {};
        })
        #(buildFirefoxXpiAddon {
        #  pname = "dark-reader";
        #  addonId = "addon@alexhulbert.com";
        #  version = "4.9.26";
        #  url = "https://alexhulbert.com/dark_reader-4.9.26-an+fx.xpi";
        #  sha256 = "01j57h137q4pp53ikydzljhygp3i9k4jflvhcs5rb2v6x9qy5qy0";
        #  meta = {};
        #})
        (buildFirefoxXpiAddon {
          pname = "midnight-lizard";
          addonId = "{8fbc7259-8015-4172-9af1-20e1edfbbd3a}";
          version = "10.7.1";
          url = "https://addons.mozilla.org/firefox/downloads/file/3711856/midnight_lizard-10.7.1-an+fx.xpi";
          sha256 = "1k19kr9phkhxlgbfvkqajyk4ivvzbvr6pxblhlah074jwy5wsdrq";
          meta = {};
        })
      ];
      profiles.default = {
        id = 0;
        settings = {
          "xpinstall.signatures.required" = false;
          "extensions.update.enabled" = false;
        };
      };
    };

    programs.vscode = {
      enable = true;
      userSettings = {
        "workbench.colorTheme" = "Wal";
      };
    };

    programs.fish.enable = true;
    programs.fish.plugins = [{
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
    
    programs.kde = {
      enable = true;
      settings = {
        kdeglobals = {
          General.BrowserApplication = "firefox.desktop";
        };
        ksplashrc = {
          KSplash = {
            Engine = "None";
            Theme = "None";
          };
        };
      };
    };
  };
}

