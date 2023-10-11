{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
in {
  xdg.configFile."wal/templates/picom-chromakey.glsl".source = ./resources/theme/picom-chromakey.glsl;
  services.picom = {
    enable = true;
    package = shim {
      name = "picom";
      cmds = ["picom"];
    };
    shadow = true;
    activeOpacity = 0.99;
    inactiveOpacity = 0.99;
    wintypes = {
      utility = {animations = "none";};
    };
    opacityRules = [
      "88:class_g = 'Spotify'"
    ];
    settings = {
      corner-radius = 20;
      backend = "glx";
      blur-background = true;
      blur-method = "dual_kawase";
      blur-strength = 12;
      xinerama-shadow-crop = true;

      unredir-if-possible = true;
      no-ewmh-fullscreen = true;
      window-shader-fg-rule = [
        (lib.strings.concatStrings [
          "${config.xdg.cacheHome}/wal/picom-chromakey.glsl:"
          "_NET_WM_STATE@[0]:32a != '_NET_WM_STATE_FULLSCREEN' && "
          "_NET_WM_STATE@[1]:32a != '_NET_WM_STATE_FULLSCREEN' && "
          "_NET_WM_STATE@[2]:32a != '_NET_WM_STATE_FULLSCREEN' && "
          "_NET_WM_STATE@[3]:32a != '_NET_WM_STATE_FULLSCREEN' && "
          "_NET_WM_STATE@[4]:32a != '_NET_WM_STATE_FULLSCREEN' && "
          "class_g != 'albert'"
        ])
      ];

      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      animations = false;
      animation-stiffness-in-tag = 200;
      animation-stiffness-tag-change = 200;

      animation-window-mass = 0.4;
      # animation-dampening = 15;
      # animation-clamping = true;

      transition = true;
    };
    shadowExclude = [
      "bounding_shaped && !rounded_corners"
    ];
    fade = true;
    fadeDelta = 5;
    vSync = true;
  };
}