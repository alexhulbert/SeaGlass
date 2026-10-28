{ config, lib, pkgs, repoPath, ... }: let
  edit = pkgs.writeScriptBin "handy-edit" (builtins.readFile ./edit.py);
in {
  home.packages = [ edit ];
  seaglass.jsonSettings."${config.xdg.dataHome}/com.pais.handy/settings_store.json".settings = {
    paste_method = "external_script";
    external_script_path = "${edit}/bin/handy-edit";
    typing_tool = "wtype";
    clipboard_handling = "dont_modify";
    keyboard_implementation = "tauri";
  };
  # Avoid slow NVIDIA Vulkan weight uploads after idle unload
  systemd.user.services.handy = import ../../session-service.nix "handy"
    "--block-signal=HUP WEBKIT_DISABLE_DMABUF_RENDERER=0 GGML_VK_DISABLE_HOST_VISIBLE_VIDMEM=1 HANDY_DISABLE_UPDATER=1 /usr/bin/handy --start-hidden";
  seaglass.dmsPlugins.handyEdit = "${repoPath}/modules/home/programs/handy/hud";
}
