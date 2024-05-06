{ config
, pkgs
, lib
, ...
}:
let
in {

  outOfStoreSymlinks.xdgConfig = {
    "hypr/hyprland.conf" = "${builtins.toString ./.}/resources/hyprland.conf";
    ags = "${builtins.toString ./.}/resources/ags";
    wallpaper = "${builtins.toString ./..}/wallpaper";
    swaync = "${builtins.toString ./.}/resources/theme/swaync";
  };

  xdg.configFile = {
    "hypr/pyprland.toml".source = (pkgs.formats.toml { }).generate "pyprland.toml" {
      pyprland.plugins = [ "workspaces_follow_focus" ];
    };

    "wal/templates/colors-hyprland.conf".source = ./resources/theme/colors-hyprland.conf;
  };

  home.file = {
    ".local/bin/lidhandler".source = ./resources/lidhandler.sh;
    ".local/bin/hyprwatchd".source = pkgs.writeScript "hyprwatchd" ''
      #!/usr/bin/env zsh
      handle() {
        case $1 in
          monitoradded*) lidhandler ;;
          monitorremoved*) lidhandler ;;
          configReloaded*) lidhandler ;;
        esac
      }
      socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
    '';
  };
}
