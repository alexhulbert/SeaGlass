{ config, lib, repoPath, inputs, ... }: {
  imports = [ inputs.coloreader.homeModules.default ];
  services.coloreader = {
    enable = true;
    electron.enable = true;
  };
  xdg.configFile."DankMaterialShell/config.d/coloreader.json".text = builtins.toJSON {
    launchPrefix = "uwsm app -- ${config.services.coloreader.electron.launcher}/bin/coloreader-electron env QT_WAYLAND_DISABLED_INTERFACES=ext_background_effect_manager_v1";
  };
  seaglass.matugen.templates.coloreader = {
    input_path = "${repoPath}/modules/home/desktop/coloreader/palette.json";
    output_path = "${config.xdg.cacheHome}/coloreader.json";
  };
}
