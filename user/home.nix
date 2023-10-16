{
  lib,
  config,
  pkgs,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  plasma-manager =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/master.tar.gz";
    })
    .defaultNix;
in {
    imports = [
      # ./pkgs/i3-sidebar.nix
      ./i3.nix
      ./terminal.nix
      ./firefox.nix
      ./picom.nix
      ./plasma.nix
      ./vscode.nix
      ./vim
      ./personal.nix
      plasma-manager.homeManagerModules.plasma-manager
    ];

    news.display = "silent";

    services.unclutter.enable = true;

    home.packages = lib.mkForce (with config.programs; [
      neovim.finalPackage
      starship.package
      pkgs.home-manager
      pkgs.comma
    ]);

    home.stateVersion = "22.11";

    programs.home-manager.enable = true;

    # Albert config
    programs.plasma.configFile."albert.conf" = {
      General = {
        frontend = "widgetsboxmodel";
        hotkey = "Ctrl+Alt+Shift+Meta+F12";
        showTray = false;
      };
      applications_xdg.enabled = true;
      calculator_qalculate.enabled = true;
      widgetsboxmodel = {
        theme = "Pywal";
        clientShadow = false;
      };
    };
    xdg.configFile."wal/templates/colors-albert.qss".source = ./resources/theme/colors-albert.qss;
    xdg.configFile."autostart/albert.desktop".source = config.lib.file.mkOutOfStoreSymlink "/usr/share/applications/albert.desktop";

    # context menu hud
    xdg.configFile."wal/templates/hud.rasi".source = ./resources/theme/hud.rasi;
    programs.rofi = {
      enable = true;
      package = shim {
        name = "rofi";
        cmds = ["rofi"];
      };
      theme = "${config.xdg.cacheHome}/wal/hud.rasi";
    };
    systemd.user.services.plasma-hud = {
      Service = {
        ExecStart = "/usr/lib/plasma-hud/plasma-hud";
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

    # konsole
    xdg.dataFile."konsole/Pywal.profile".source = ./resources/konsole.profile;
    xdg.dataFile."kxmlgui5/konsole/sessionui.rc".source = ./resources/konsole.xml;

    systemd.user.services.cleanup = {
      Unit.Description = "Clean and optimize Nix store on boot";
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScriptBin "clean-nix-store" ''
          nix-store --gc
          nix-store --optimize
        ''}/bin/clean-nix-store";
      };
    };
}
