{ lib, config, pkgs, ... }:

{
  imports = [
    (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz}/nixos")
  ];
  home-manager.users.alex = { config, ... }: {
    imports = [
      ./libs/kde-home-manager.nix
    ];
    home.file = {
      ".local/share/kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;
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

    xdg.configFile."fish/conf.d/any-nix-shell.fish".text = ''
      any-nix-shell fish --info-right | source
    '';

    xdg.configFile."fish/conf.d/hm-session-vars.fish".text = ''
      set --prepend fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
      fenv source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars-2.sh > /dev/null
      set -e fish_function_path[1]
    '';

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

