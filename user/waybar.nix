{
  config,
  pkgs,
  lib,
  ...
}: let
  hypr-plasmoid = pkgs.rustPlatform.buildRustPackage {
    pname = "hypr-plasmoid";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "alexhulbert";
      repo = "hypr-plasmoid";
      rev = "9567639ab6a65c708ab941646b8e64c99e3c62cd";
      hash = "sha256-cM9x1ob7Z+RSnzSu5j5uVN0FRI8isC5MN/Kv9UBpQz4=";
    };
    cargoHash = "sha256-eXSMwDzQB6wh8grTLVxbS53i8Dv2sAStBc4I5/Ph/sM=";
  };
  waybar-patched = pkgs.waybar.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "andresilva";
      repo = "Waybar";
      rev = "bbb7f377612ba66bcd2d11541cea127ff5b0b284";
      hash = "sha256-2YlUBiKbQnqZf6jX7ePtVK96+rtCHo1sIPCht6B99mY=";
    };
    mesonFlags = (old.mesonFlags or []) ++ ["-Dcava=disabled"];
  });
  plasmoids = {
    eventcal = {
      title = "Event Calendar";
      width = 1000;
      height = 500;
      plasmoid = "org.kde.plasma.eventcalendar";
    };
    battery = {
      title = "Power Management|Power and Battery";
      width = 500;
      height = 270;
      plasmoid = "org.kde.plasma.battery";
    };
    network = {
      title = "Networks";
      width = 500;
      height = 500;
      plasmoid = "org.kde.plasma.networkmanagement";
    };
    bluetooth = {
      title = "Bluetooth";
      width = 500;
      height = 500;
      plasmoid = "org.kde.plasma.bluetooth";
    };
    audio = {
      title = "Audio Volume";
      width = 600;
      height = 270;
      plasmoid = "org.kde.plasma.volume";
    };
    kde-connect = {
      title = "KDE Connect";
      width = 500;
      height = 500;
      plasmoid = "org.kde.kdeconnect";
    };
  };
in {
  programs.waybar = {
    enable = true;
    package = waybar-patched;
    style = ./files/theme/waybar.css;
    settings = [
      {
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
        tray = {
          spacing = 10;
          icons = {
            "plasmawindowed_org.kde.plasma.bluetooth" = false;
            "plasmawindowed_org.kde.plasma.battery" = false;
            "plasmawindowed_org.kde.plasma.networkmanagement" = false;
            "plasmawindowed_org.kde.kdeconnect" = false;
          };
        };
        "custom/kde-connect" = {
          format = "󰄜";
          on-click = "hypr-plasmoid toggle kde-connect";
          on-click-right = "hypr-plasmoid config kde-connect";
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
          on-click = "sleep 0.1 && hypr-plasmoid hide-all && swaync-client -t -sw";
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
          on-click = "hypr-plasmoid toggle audio";
          on-click-right = "hypr-plasmoid config audio";
        };
        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          format-connected-battery = "{icon}";
          format-icons = ["󰤾" "󰤿" "󰥀" "󰥁" "󰥂" "󰥃" "󰥄" "󰥅" "󰥆" "󰥈"];
          on-click = "hypr-plasmoid toggle bluetooth";
          on-click-right = "hypr-plasmoid config bluetooth";
        };
        network = {
          format = "{icon} ";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format-linked = "󰤩 ";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰤮 ";
          on-click = "hypr-plasmoid toggle network";
          on-click-right = "hypr-plasmoid config network";
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
          on-click = "hypr-plasmoid toggle battery";
          on-click-right = "hypr-plasmoid config battery";
        };
        clock = {
          format = "{:%I:%M %p}";
          on-click = "hypr-plasmoid toggle eventcal";
          on-click-right = "hypr-plasmoid config eventcal";
        };
      }
    ];
  };

  xdg.configFile."hypr/plasmoids.json".text = builtins.toJSON plasmoids;

  home.file.".local/bin/hypr-plasmoid".source = "${hypr-plasmoid}/bin/hypr-plasmoid";
}
