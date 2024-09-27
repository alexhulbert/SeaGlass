{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  plasma-waybar = ./resources/plasma-waybar.py;
  plasmoids = {
    eventcal = {
      title = "Calendar";
      width = 500;
      height = 500;
      margin_right = 0;
      plasmoid = "org.kde.plasma.calendar";
    };
    battery = {
      title = "Power and Battery";
      width = 500;
      height = 270;
      margin_right = 60;
      plasmoid = "org.kde.plasma.battery";
    };
    network = {
      title = "Networks";
      width = 500;
      height = 500;
      margin_right = 80;
      plasmoid = "org.kde.plasma.networkmanagement";
    };
    bluetooth = {
      title = "Bluetooth";
      width = 500;
      height = 500;
      margin_right = 105;
      plasmoid = "org.kde.plasma.bluetooth";
    };
    audio = {
      title = "Audio Volume";
      width = 600;
      height = 270;
      margin_right = 125;
      plasmoid = "org.kde.plasma.volume";
    };
    kde-connect = {
      title = "KDE Connect";
      width = 500;
      height = 500;
      margin_right = 150;
      plasmoid = "org.kde.kdeconnect";
    };
  };
in {
  programs.waybar = {
    enable = true;
    package = shim {
      name = "waybar";
      cmds = ["waybar"];
    };
    style = ./resources/theme/waybar.css;
    settings = [{
      layer = "top";
      spacing = 8;
      modules-left = ["hyprland/workspaces"];
      modules-center = [];
      modules-right = [
        "tray"
        "custom/notification"
        "custom/kde-connect"
        "pulseaudio"
        "bluetooth"
        "network"
        "battery"
        "clock"
      ];
      "hyprland/workspaces".all-outputs = true;
      tray.spacing = 10;
      "custom/kde-connect" = {
          format = "󰄜";
          on-click = "${plasma-waybar} toggle kde-connect";
      };
      "custom/notification" = {
        tooltip = false;
        format = "{icon} ";
        format-icons = {
          notification = "󱅫";
          none = "󰂚";
          dnd-notification = "󱏧";
          dnd-none = "󱏧";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "sleep 0.1 && swaync-client -t -sw";
      };
      pulseaudio = {
        format = "{icon}";
        format-bluetooth = "{icon}";
        format-bluetooth-muted = "󰝟 ";
        format-muted = "󰝟 ";
        format-icons = {
          default = ["󰕿 " "󰖀 " "󰕾 "];
          headphone = "󰋋 ";
        };
        on-click = "${plasma-waybar} toggle audio";
      };
      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-connected = "󰂱";
        format-connected-battery = "󰂱";
        on-click = "${plasma-waybar} toggle bluetooth";
      };
      network = {
        format = "{icon} ";
        format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
        format-linked = "󰤩 ";
        format-ethernet = "󰈀 ";
        format-disconnected = "󰤮 ";
        on-click = "${plasma-waybar} toggle network";
      };
      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} ";
        format-charging = " ";
        format-full = " ";
        format-icons = ["" "" "" "" ""];
        on-click = "${plasma-waybar} toggle battery";
      };
      clock = {
        format = "{:%I:%M %p}";
        on-click = "${plasma-waybar} toggle eventcal";
      };
    }];
  };

  home.file.".local/bin/plasma-waybar".source = plasma-waybar;

  xdg.configFile = {
    "hypr/plasmoids.json".text = builtins.toJSON plasmoids;
    "hypr/plasmoids.conf".text = builtins.concatStringsSep "\n" (
      lib.attrsets.mapAttrsToList (plasmoid_name: plasmoid: ''
        windowrulev2 = move 0 -200%,title:^(${plasmoid.title})$
        windowrulev2 = workspace special:scratch_${plasmoid_name} silent,title:^(${plasmoid.title})$
        windowrulev2 = size ${toString plasmoid.width} ${toString plasmoid.height}, title:^(${plasmoid.title})$
      '') plasmoids
    );
  };
}
