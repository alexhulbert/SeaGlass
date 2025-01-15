{ config
, pkgs
, lib
, ...
}:
let
  dndwatchdCfg = {
    gistId = "a8d9c7b6cdfc46dd7ace7d050787f04c";
    commitSha = "097efbdc10d52d89ea720e9303321ea04063d4ea";
    sha = "sha256:0im4xgkbppg3wagrpk00gdfkhinf9hynwa8cg7scc5q4hc8x0ywb";
    find = "dunstctl set-paused {str(write_opt).lower()}";
    replace = "swaync-client -d{\"n\" if write_opt else \"f\"}";
  };

  dndwatchdOrig = builtins.readFile (
    builtins.fetchurl {
      url = "https://gist.githubusercontent.com/Half-Shot/${dndwatchdCfg.gistId}/raw/${dndwatchdCfg.commitSha}/autopause-notifications.py";
      sha256 = dndwatchdCfg.sha;
    }
  );
  dndwatchd = builtins.replaceStrings [dndwatchdCfg.find] [dndwatchdCfg.replace] dndwatchdOrig;

  hyprwatchd = ''
    #!/usr/bin/env zsh
    handle() {
      case $1 in
        monitoradded*) lidhandler ;;
        monitorremoved*) lidhandler ;;
        configReloaded*) lidhandler ;;
        # openwindow*) echo "$*" >> /home/alex/windows.log
      esac
    }
    socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
  '';
in {

  outOfStoreSymlinks.xdgConfig = {
    "hypr/hyprland.conf" = "${builtins.toString ./.}/files/hyprland.conf";
    "hypr/hyprlock.conf" = "${builtins.toString ./.}/files/hyprlock.conf";
    ags = "${builtins.toString ./.}/files/ags";
    wallpaper = "${builtins.toString ./..}/wallpaper";
    swaync = "${builtins.toString ./.}/files/theme/swaync";
  };

  xdg.configFile = {
    "hypr/pyprland.toml".source = ./files/pyprland.toml;
    "wal/templates/colors-hyprland.conf".source = ./files/theme/colors-hyprland.conf;

    "wal/templates/wezterm-wal.toml".source = ./files/theme/wezterm-wal.toml;
    "wezterm/wezterm.lua".source = ./files/wezterm.lua;
  };

  home.file = {
    ".local/bin/lidhandler".source = ./files/lidhandler.sh;
    ".local/bin/hyprwatchd".source = pkgs.writeScript "hyprwatchd" hyprwatchd;
    ".local/bin/dndwatchd".source = pkgs.writeScript "dndwatchd" dndwatchd;
  };

  mutableConfig.files = {
    "${config.xdg.configHome}/primenote/settings.json" = {
      "profile default" = {
        width = 300;
        height = 210;
        zoom = 5;
        mode = "html";
        style = "toolbar.css";
        palette = "wal.css";
      };
    };
  };
}
