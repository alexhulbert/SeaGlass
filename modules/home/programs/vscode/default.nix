{ config, repoPath, pkgs, lib, mergeJson, ... }: let
  theme = pkgs.fetchurl {
    name = "dms-theme.vsix";
    url = "https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell/v1.6.3/quickshell/matugen/dms-theme.vsix";
    hash = "sha256-MI1x1wiqvwg/N89oMuNVp0qlRT84ubvuMjtpkX0WKQY=";
  };
in {
  seaglass.matugen.templates.vscode-colors = {
    input_path = "${repoPath}/modules/home/programs/vscode/colors.json";
    output_path = "${config.xdg.cacheHome}/vscode-colors.json";
    post_hook = "${mergeJson} ${lib.escapeShellArg "${config.xdg.configHome}/Code/User/settings.json"} ${lib.escapeShellArg "${config.xdg.cacheHome}/vscode-colors.json"}";
  };

  programs.git.settings = {
    merge.tool = "vscode";
    mergetool = {
      keepBackup = false;
      vscode.cmd = ''code --wait --merge "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'';
    };
    diff.tool = "vscode";
    difftool.vscode.cmd = ''code --wait --diff "$LOCAL" "$REMOTE"'';
  };
  home.activation.vscodeTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! /usr/bin/code --list-extensions | ${pkgs.gnugrep}/bin/grep -Fxiq DankLinux.dms-theme; then
      run /usr/bin/code --install-extension ${theme}
    fi
  '';

  seaglass.jsonSettings."${config.xdg.configHome}/Code/User/settings.json" = {
    "window.autoDetectColorScheme" = true;
    "workbench.preferredLightColorTheme" = "Dynamic Base16 DankShell (Light)";
    "workbench.preferredDarkColorTheme" = "Dynamic Base16 DankShell (Dark)";
    "workbench.experimental.modernUIEditorTabStyle" = "pill";
    "breadcrumbs.enabled" = false;
    "window.menuBarVisibility" = "toggle";
    "window.titleBarStyle" = "custom";
    "editor.minimap.enabled" = false;
    "editor.emptySelectionClipboard" = false;
    "editor.scrollbar.horizontal" = "hidden";
    "editor.scrollbar.vertical" = "hidden";
    "editor.overviewRulerBorder" = false;
    "editor.hideCursorInOverviewRuler" = true;
    "editor.occurrencesHighlight" = false;
    "editor.inlineSuggest.enabled" = true;
    "vim.handleKeys" = lib.genAttrs [ "<C-k>" "<C-a>" "<C-t>" "<C-g>" "<C-f>" "<C-c>" "<C-v>" "<C-x>" "<C-o>" "<C-n>" ] (_: false);
    "vim.enableNeovim" = true;
    "vim.startInInsertMode" = true;
    "editor.fontLigatures" = true;
    "editor.fontFamily" = "FiraCode Nerd Font";
    "git.mergeEditor" = true;
    "diffEditor.codeLens" = true;

    "terminal.integrated.commandsToSkipShell" = [ "-workbench.action.terminal.goToRecentDirectory" ];
    "terminal.integrated.env.linux" = {
      "EDITOR" = "code --wait";
      "VISUAL" = "code --wait";
    };
  };

  home.file.".local/bin/code" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec env -u LD_PRELOAD /usr/bin/code "$@"
    '';
  };

  xdg.configFile = lib.genAttrs [ "code-flags.conf" "electron-flags.conf" ] (_: { text = "--ozone-platform=wayland\n"; }) // {
    "Code/User/keybindings.json".source = (pkgs.formats.json {}).generate "keybindings.json" [
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
  };
}
