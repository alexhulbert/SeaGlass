{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  xdg.configFile = {
    "hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink
      "${builtins.toString ./.}/resources/hyprland.conf";

    "hypr/pyprland.toml".source = (pkgs.formats.toml {}).generate "pyprland.toml" {
      pyprland.plugins = ["workspaces_follow_focus"];
    };

    "wal/templates/colors-hyprland.conf".source = ./resources/theme/colors-hyprland.conf;

    ags.source = config.lib.file.mkOutOfStoreSymlink
      "${builtins.toString ./.}/resources/ags";

    wallpaper.source = config.lib.file.mkOutOfStoreSymlink
      "${builtins.toString ./..}/wallpaper";

    swaync.source = config.lib.file.mkOutOfStoreSymlink
      "${builtins.toString ./.}/resources/theme/swaync";
  };

  home.file = {
    ".local/bin/lidhandler".source = ./resources/lidhandler.sh;
    ".local/bin/hyprwalld".source = pkgs.writeScript "hyprwalld" ''
        #!/usr/bin/env zsh
        refresh_wallpaper() {
          sleep 1
          swww init
          swww img $(readlink ~/.cache/wallpaper) --transition-step=255
        }
        handle() {
          case $1 in
            monitoradded*) refresh_wallpaper ;;
            monitorremoved*) refresh_wallpaper ;;
          esac
        }
        socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
    '';
  };
}
