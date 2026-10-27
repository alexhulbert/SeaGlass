{ config, lib, pkgs, ... }: let
  duxPlugins = pkgs.fetchFromGitHub {
    owner = "alexhulbert";
    repo = "dux-plugins";
    rev = "ae9f020a5caab6732cd013a264f85fa5ea80dc6a";
    hash = "sha256-KN0F+c+wz4/J9Hm2hSoh95V+hsSZydJN4fsgIIANZF4=";
  };
in {
  options.seaglass = {
    dmsPlugins = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "DMS plugin directories";
    };
    dmsPluginLock = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "DMS plugin lockfile";
    };
    hiddenApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Launcher applications to hide";
    };
  };

  config = {
    seaglass.hiddenApps = [
      "appimagelaunchersettings" "btop" "cmake-gui" "cups" "htop" "hyprmoncfg" "lstopo" "nvim"
      "org.kde.kdeconnect.nonplasma" "org.kde.kdeconnect.sms" "pavucontrol-qt" "qv4l2" "qvidcap" "uuctl"
    ];
    xdg.dataFile = lib.genAttrs (map (id: "applications/${id}.desktop") config.seaglass.hiddenApps)
      (path: { text = "[Desktop Entry]\nType=Application\nName=${baseNameOf path}\nHidden=true\n"; })
      // lib.mapAttrs' (id: path: lib.nameValuePair "DankMaterialShell/plugins/${id}" { source = config.lib.file.mkOutOfStoreSymlink path; }) config.seaglass.dmsPlugins;
    xdg.configFile."DankMaterialShell/plugins".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/DankMaterialShell/plugins";

    programs.zsh.shellAliases.relock = "dms ipc call lock lock";
    seaglass.sessionUnits = {
      dms = "Environment=QT_WAYLAND_DISABLED_INTERFACES=\n";
      dcal = "";
    };

    seaglass.dmsPluginLock = ./plugins.lock.json;
    seaglass.dmsPlugins.dankKDEConnect = "${duxPlugins}/DankKDEConnect";
    home.activation.dmsPlugins = lib.mkIf (config.seaglass.dmsPluginLock != null)
      (lib.hm.dag.entryAfter [ "linkGeneration" ] "run /usr/bin/dms plugins restore ${config.seaglass.dmsPluginLock}\n");
  };
}
