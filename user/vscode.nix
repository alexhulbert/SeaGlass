{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  theme = (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "beautiful-ui";
      publisher = "swashata";
      version = "1.7.0";
      sha256 = "sha256-5eayRGrM5uAzAQL0x3Vqdl6+Hcv4RoXznjg/bU6Vx/k=";
    };
  });
  themeJson = builtins.fromJSON (builtins.readFile "${theme}/share/vscode/extensions/swashata.beautiful-ui/themes/Tomorrow Subliminal-color-theme.json");
in {
  config.programs.vscode = {
    enable = true;
    userSettings = {
      "workbench.colorTheme" = "Wal";
      "breadcrumbs.enabled" = false;
      "window.menuBarVisibility" = "toggle";
      "window.titleBarStyle" = "custom";
      "editor.minimap.enabled" = false;
      "editor.scrollbar.horizontal" = "hidden";
      "editor.scrollbar.vertical" = "hidden";
      "editor.overviewRulerBorder" = false;
      "editor.hideCursorInOverviewRuler" = true;
      "editor.occurrencesHighlight" = false;
      "editor.inlineSuggest.enabled" = true;
      "vim.handleKeys" = {
        "<C-k>" = false;
        "<C-a>" = false;
        "<C-t>" = false;
        "<C-g>" = false;
        "<C-f>" = false;
        "<C-c>" = false;
        "<C-v>" = false;
        "<C-x>" = false;
        "<C-o>" = false;
        "<C-n>" = false;
      };
      "vim.enableNeovim" = true;
      "vim.startInInsertMode" = true;
      "editor.fontLigatures" = true;
      "editor.fontFamily" = "FiraCode Nerd Font";
      "editor.tokenColorCustomizations" = {
        "textMateRules" = themeJson.tokenColors;
      };
      "arduino.additionalUrls" = [
        "https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json"
      ];
      "arduino.useArduinoCli" = true;

      "mergetool.keepTemporaries" = false;
      "mergetool.keepBackup" = false;
      "mergetool.code.cmd" = "node \"$BASE\"";
      "merge.tool" = "code";
      "merge.conflictstyle" = "merge";
      "diffEditor.codeLens" = true;

      "terminal.integrated.commandsToSkipShell" = [ "-workbench.action.terminal.goToRecentDirectory" ];
    };
    keybindings = [
      {
        key = "ctrl+c";
        command = "workbench.action.terminal.copySelection";
        when = "terminalFocus && terminalProcessSupported && terminalTextSelected";
      }
      {
        key = "ctrl+v";
        command = "workbench.action.terminal.paste";
        when = "terminalFocus";
      }
      {
        key = "shift shift";
        command = "workbench.action.quickOpen";
      }
      {
        key = "ctrl ctrl";
        command = "workbench.action.showCommands";
      }
    ];
    extensions = with pkgs.vscode-utils; [
      theme
      (buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "wal-theme";
          publisher = "dlasagno";
          version = "1.2.0";
          sha256 = "sha256-X16N5ClNVLtWST64ybJUEIRo6WgDCzODhBA9ScAHI5w=";
        };
      })
    ];
  };

  config.xdg.configFile = let
    electronOptions = ''
      --enable-features=UseOzonePlatform
      --ozone-platform=wayland
    '';
  in {
    "code-flags.conf".text = electronOptions;
    "electron-flags.conf".text = electronOptions;
    "electron12-flags.conf".text = electronOptions;
  };

  # make settings.json mutable
  config.home = let
    configFilePath = "${config.xdg.configHome}/Code/User/settings.json";
    userSettings = config.programs.vscode.userSettings;
    jsonFormat = pkgs.formats.json {};
  in {
    file."${configFilePath}".enable = lib.mkForce false;
    activation.injectVscodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      tmp="$(mktemp)"
      touch "${configFilePath}"
      if [[ -v DRY_RUN ]]; then
        echo tmp="\$(mktemp)"
        echo ${pkgs.jq}/bin/jq -s "'reduce .[] as \$x ({}; . * \$x)'" "${
          jsonFormat.generate "vscode-user-settings" userSettings
        }" "${configFilePath}" ">" "$tmp"
      else
        ${pkgs.jq}/bin/jq -s 'reduce .[] as $x ({}; . * $x)' "${
          jsonFormat.generate "vscode-user-settings" userSettings
        }" "${configFilePath}" > "$tmp"
      fi
      $DRY_RUN_CMD mv "$tmp" "${configFilePath}"
    '';
  };
}
