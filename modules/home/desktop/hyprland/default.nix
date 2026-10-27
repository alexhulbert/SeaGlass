{ config, lib, pkgs, repoPath, link, ... }: let
  cheatsheet = pkgs.runCommand "seaglass-cheatsheet" { nativeBuildInputs = [ pkgs.lua5_4 pkgs.python3 ]; } ''
    mkdir hypr home
    cp ${./hyprland.lua} hypr/hyprland.lua
    cp ${./scratchpads.lua} hypr/scratchpads.lua
    cp ${./layouts.lua} hypr/layouts.lua
    cp ${config.xdg.configFile."hypr/sidebars.lua".source} hypr/sidebars.lua
    lua ${./capture-binds.lua} hypr "$PWD/home" | python3 ${./cheatsheet.py} > "$out"
  '';
in {
  programs.zsh.shellAliases.sw = "home-manager switch && hyprctl reload config-only";
  seaglass.dmsPlugins.seaglassScrolling = "${repoPath}/modules/home/desktop/hyprland/scrolling";
  seaglass.jsonSettings."${config.xdg.configHome}/DankMaterialShell/plugin_settings.json".seaglassScrolling.enabled = true;

  xdg.configFile = {
    "hypr/xdph.conf".text = ''
      screencopy {
        custom_picker_binary = hyprland-preview-share-picker
      }
    '';
    "hyprland-preview-share-picker/config.yaml".text = ''
      stylesheets: [style.css]
      window:
        width: 1000
        height: 650
      image:
        resize_size: 500
      windows:
        max_per_row: 3
    '';
    "hyprland-preview-share-picker/style.css".source = link "modules/home/desktop/hyprland/share-picker.css";
    "hypr/hyprland.lua".source = link "modules/home/desktop/hyprland/hyprland.lua";
    "hypr/scratchpads.lua".source = link "modules/home/desktop/hyprland/scratchpads.lua";
    "hypr/layouts.lua".source = link "modules/home/desktop/hyprland/layouts.lua";
    "hypr/sidebars.lua".text = lib.mkDefault "return {}\n";
    "hypr/glass.glsl".source = link "modules/home/desktop/hyprland/glass.glsl";
    "DankMaterialShell/cheatsheets/seaglass.json".source = cheatsheet;
  };

  xdg.configFile."systemd/user/xdg-desktop-portal-gtk.service.d/signals.conf".text =
    "[Service]\nExecStart=\nExecStart=/usr/bin/nohup /usr/lib/xdg-desktop-portal-gtk\n";

  seaglass.matugen.templates.glass = {
    input_path = "${repoPath}/modules/home/desktop/hyprland/glass.lua";
    output_path = "${config.xdg.configHome}/hypr/dms/glass.lua";
    post_hook = "hyprctl reload config-only";
  };
}
