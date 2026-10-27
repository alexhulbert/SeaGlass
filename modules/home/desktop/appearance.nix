{ config, lib, pkgs, ... }: let
  shim = import ../system-command.nix { inherit pkgs; };
  kwrite = file: groups: lib.concatStrings (lib.mapAttrsToList (group: keys: lib.concatStrings (lib.mapAttrsToList (key: value:
    "run /usr/bin/kwriteconfig6 --file ${file} --group ${lib.escapeShellArg group} --key ${lib.escapeShellArg key} ${lib.escapeShellArg (if builtins.isBool value then lib.boolToString value else toString value)}\n"
  ) keys)) groups);
  gtkCss = pkgs.writeText "gtk.css" ''@import url("dank-colors.css");'';
in {
  systemd.user.sessionVariables.GSK_RENDERER = "gl";

  home.activation.dmsGtk = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run install -Dm644 /dev/null ${lib.escapeShellArg config.xdg.configHome}/gtk-3.0/gtk.css
    run install -Dm644 ${gtkCss} ${lib.escapeShellArg config.xdg.configHome}/gtk-4.0/gtk.css
  '';

  xdg.dataFile."flatpak/overrides/global".text = let
    paths = [
      "xdg-config/gtk-3.0:ro"
      "xdg-config/gtk-4.0:ro"
      "xdg-data/themes:ro"
      "${config.xdg.stateHome}/seaglass/icons:ro"
      "/nix/store:ro"
    ];
  in ''
    [Context]
    filesystems=${lib.concatStringsSep ";" paths};
    [Environment]
    QT_QPA_PLATFORMTHEME=gtk3
    GSK_RENDERER=gl
  '';

  dconf.settings."org/gnome/TextEditor".recolor-window = false;

  seaglass.jsonSettings."${config.xdg.configHome}/qtengine/config.json" = builtins.fromJSON (builtins.readFile ./qtengine.json);

  gtk = {
    enable = true;
    font = { name = "SFNS Display"; size = 11; };
    cursorTheme = { name = "Bibata-Modern-Ice"; size = 32; };
    gtk3.extraConfig = {
      gtk-modules = "";
      gtk-decoration-layout = "icon:minimize,maximize,close";
    };
    gtk4.extraConfig.gtk-decoration-layout = config.gtk.gtk3.extraConfig.gtk-decoration-layout;
  };

  services.xsettingsd = {
    enable = true;
    package = shim "xsettingsd";
    settings = {
      "Gtk/FontName" = "${config.gtk.font.name} ${toString config.gtk.font.size}";
      "Gtk/CursorThemeName" = config.gtk.cursorTheme.name;
      "Gtk/CursorThemeSize" = config.gtk.cursorTheme.size;
      "Gtk/DecorationLayout" = config.gtk.gtk3.extraConfig.gtk-decoration-layout;
      "Net/IconThemeName" = "Papirus-Colors";
    };
  };
  systemd.user.services.xsettingsd = {
    Unit.After = [ "graphical-session.target" ];
    Service.Slice = "session-graphical.slice";
  };

  home.activation.kdeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] (kwrite "kdeglobals" {
    General = {
      ColorScheme = "DankMatugenDark";
      fixed = "FiraCode Nerd Font,11,-1,5,50,0,0,0,0,0";
      font = "SFNS Display,11,-1,5,50,0,0,0,0,0";
      menuFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
      smallestReadableFont = "SFNS Display,9,-1,5,50,0,0,0,0,0";
      toolBarFont = "SFNS Display,11,-1,5,50,0,0,0,0,0";
      BrowserApplication = "firefox.desktop";
    };
    KDE.widgetStyle = "Darkly";
    Icons.Theme = "Papirus-Colors";
  } + kwrite "zoomus.conf" { General.xwayland = false; });
  xdg.configFile.darklyrc.text = "[Style]\nMenuOpacity=80\n";

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
    };
  };
}
