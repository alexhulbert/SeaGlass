{ config, lib, repoPath, link, ... }: {
  options.seaglass.sessionUnits = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = {};
  };

  config = {
    home.file = lib.mapAttrs' (name: _: lib.nameValuePair
      ".config/systemd/user/graphical-session.target.wants/${name}.service"
      { source = config.lib.file.mkOutOfStoreSymlink "/usr/lib/systemd/user/${name}.service"; }
    ) config.seaglass.sessionUnits // {
      ".hushlogin".text = "";
      ".local/bin/switch-to-windows".source = link "modules/home/desktop/session/windows/switch-to-windows";
    };
    xdg.configFile = lib.mapAttrs' (name: extra: lib.nameValuePair
      "systemd/user/${name}.service.d/session.conf"
      { text = "[Unit]\nPartOf=graphical-session.target\n[Service]\nSlice=session-graphical.slice\n${extra}"; }
    ) config.seaglass.sessionUnits // {
      "uwsm/env-hyprland".source = link "modules/home/desktop/session/env-hyprland";
    };
    seaglass.dmsPlugins.switchToWindows = "${repoPath}/modules/home/desktop/session/windows";

    programs.zsh.shellAliases.ldm = "uwsm stop";
    programs.zsh.profileExtra = ''
      if uwsm check may-start -q; then
        exec uwsm start -e -D Hyprland hyprland.desktop
      fi
    '';
  };
}
