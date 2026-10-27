{ config, lib, pkgs, link, ... }: let
  gpgKey = "54F7B202E38A7ED2";
  shim = import ../../modules/home/system-command.nix { inherit pkgs; };
in {
  imports = [
    ../../modules/home
    ../../modules/home/desktop
    ../../modules/home/xps-16.nix
    ./ableton
  ];
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  seaglass.hiddenApps = [
    "dev.lizardbyte.app.Sunshine" "org.kde.kwatchgnupg" "org.kicad.bitmap2component" "org.kicad.eeschema"
    "org.kicad.gerbview" "org.kicad.pcbcalculator" "org.kicad.pcbnew"
    "org.torproject.torbrowser-launcher" "org.torproject.torbrowser-launcher.settings"
    "jconsole-java-openjdk" "jconsole-java17-openjdk" "jconsole-java21-openjdk"
    "jshell-java-openjdk" "jshell-java17-openjdk" "jshell-java21-openjdk" "nvtop" "xdvi"
  ];
  seaglass.iconOverrides = {
    "FlashPrint5" = "SuperSlicer";
    "GameMaker-Beta" = "godot";
    "Handy" = "org.gnome.SoundRecorder";
    "ableton" = "assistant";
    "beeper" = "Beeper";
    "beepertexts" = "Beeper";
    "claude-desktop" = "claude";
    "dev.duxlabs.calendar" = "office-calendar";
    "dev.duxlabs.shell" = "preferences-system";
    "com.raspberrypi.rpi-imager" = "org.raspberrypi.rpi-imager";
    "com.todoist.Todoist" = "dev.edfloreshz.Tasks";
    "flashforge5" = "SuperSlicer";
    "handy" = "org.gnome.SoundRecorder";
    "learnharness" = "readest";
    "ledger-live-desktop" = "org.gnome.World.Secrets";
    "monero" = "kmymoney";
    "monero-gui" = "kmymoney";
    "openscad" = "librecad";
    "rpi-imager" = "org.raspberrypi.rpi-imager";
    "soulseek" = "nicotine-plus";
    "soulseekqt" = "nicotine-plus";
    "spek" = "gtkwave";
    "todoist" = "dev.edfloreshz.Tasks";
    "uefitool" = "chipedit";
  };
  seaglass.jsonSettings = {
    "${config.xdg.configHome}/DankMaterialShell/settings.json" =
      builtins.fromJSON (builtins.readFile ./config/DankMaterialShell/settings.json);
    "${config.xdg.dataHome}/com.pais.handy/settings_store.json".settings = {
      selected_model = "handy-computer/parakeet-unified-en-0.6b-gguf/parakeet-unified-en-0.6b-Q8_0.gguf";
      selected_language = "en";
      shortcut_activation = "toggle";
      start_hidden = true;
      autostart_enabled = false;
      update_checks_enabled = false;
      show_whats_new_on_update = true;
      show_tray_icon = true;
      theme = "system";
      sound_theme = "marimba";
      audio_feedback = true;
      audio_feedback_volume = 1.0;
      overlay_position = "bottom";
      overlay_style = "live";
      filler_word_removal_enabled = true;
      word_correction_threshold = 0.18;
      recording_retention_period = "never";
      history_limit = 5;
      hold_threshold_ms = 300;
      model_unload_timeout = "min5";
      vad_enabled = false;
      onboarding_completed = true;
    };
  };

  # Omit --gtk-version=3 because DMS sends HUP to command lines containing gtk
  xdg.dataFile."applications/slack.desktop".text = ''
    [Desktop Entry]
    Name=Slack
    StartupWMClass=Slack
    Comment=Slack Desktop
    GenericName=Slack Client for Linux
    Exec=/usr/bin/slack -s %U
    Icon=slack
    Type=Application
    StartupNotify=true
    Categories=GNOME;GTK;Network;InstantMessaging;
    MimeType=x-scheme-handler/slack;
  '';
  xdg.dataFile."applications/FlashPrint5.desktop".text = ''
    [Desktop Entry]
    GenericName=FlashPrint5
    Name=FlashForge 3D Printer Control Software v5
    MimeType=text/plain;
    Exec=env QT_QPA_PLATFORM=xcb /usr/bin/flashprint
    X-KDE-StartupNotify=true
    X-KDE-HasTempFileOption=true
    Icon=flashforge5
    Type=Application
    Terminal=false
    Categories=Qt;Utility;
  '';
  xdg.configFile."vimfx/config.js".source = ./config/firefox/vimfx.js;
  xdg.configFile."vimfx/frame.js".text = "";
  programs.firefox.profiles.default.settings = {
    "extensions.VimFx.config_file_directory" = "${config.xdg.configHome}/vimfx";
    "security.sandbox.content.read_path_whitelist" = "${config.xdg.configHome}/vimfx/";
  };
  home.file.".mozilla/firefox/default/chrome/userChrome.css".source = link "users/alex/config/firefox/userChrome.css";
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/codex" = "chatgpt.desktop";
    "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    "x-scheme-handler/discord-455712169795780630" = "discord-455712169795780630.desktop";
    "x-scheme-handler/element" = "Beeper.desktop";
    "x-scheme-handler/rpi-imager" = "com.raspberrypi.rpi-imager-uri-handler.desktop";
    "x-scheme-handler/slack" = "slack.desktop";
  };
  seaglass.jsonSettings."${config.xdg.configHome}/Code/User/settings.json" = {
    "arduino.additionalUrls" = [ "https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json" ];
    "arduino.useArduinoCli" = true;
    "rust-analyzer.check.command" = "clippy";
  };
  programs.gpg = {
    enable = true;
    package = shim [ "gpg" "gpg-agent" "gpgconf" "gpg-connect-agent" ];
    settings.default-key = gpgKey;
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableScDaemon = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    extraConfig = "pinentry-program /usr/bin/pinentry-qt";
  };

  programs.git = {
    settings.user.name = "alexhulbert";
    settings.user.email = "alex@alexhulbert.com";
    settings.url."https://invent.kde.org/".insteadOf = "kde:";
    settings.url."ssh://git@invent.kde.org/".pushInsteadOf = "kde:";
    signing = {
      key = gpgKey;
      signByDefault = true;
    };
  };
  programs.jujutsu.settings = {
    user = { name = "alexhulbert"; email = "alex@alexhulbert.com"; };
    signing = { behavior = "own"; backend = "gpg"; key = gpgKey; };
  };

  # shorter names for ~ subdirs
  xdg.userDirs = {
    desktop = "${config.home.homeDirectory}/tmp";
    download = "${config.home.homeDirectory}/tmp";
    documents = "${config.home.homeDirectory}/files";
    music = "${config.home.homeDirectory}/files/media";
    pictures = "${config.home.homeDirectory}/files/media";
    videos = "${config.home.homeDirectory}/files/media";
  };

  xdg.configFile = {
    "hypr/sidebars.lua".source = ./config/hypr/sidebars.lua;
    "DankMaterialShell/config.d/icons.json".text = builtins.toJSON {
      iconThemeDark = "Papirus-Colors-Dark";
      iconThemeLight = "Papirus-Colors";
      iconThemePerMode = true;
      appIdSubstitutions = [
        { pattern = "org.quickshell"; replacement = "dev.duxlabs.shell"; type = "exact"; }
        { pattern = "Spotify"; replacement = "spotify"; type = "exact"; }
        { pattern = "beepertexts"; replacement = "beeper"; type = "exact"; }
        { pattern = "home assistant desktop"; replacement = "homeassistant-desktop"; type = "exact"; }
        { pattern = "com.transmissionbt.transmission"; replacement = "transmission-gtk"; type = "contains"; }
        { pattern = "^steam_app_(\\d+)$"; replacement = "steam_icon_$1"; type = "regex"; }
        { pattern = "^(GameMaker-Beta|/opt/GameMaker-Beta/GameMaker\\.png)$"; replacement = "godot"; type = "regex"; }
      ];
    };
    "coloreader/openai-codex-electron.js".source = link "users/alex/config/coloreader/openai-codex-electron.js";
    "dms-airplay.json".text = builtins.toJSON {
      moonlight = [{
        receiver = "14:CF:2F:46:FA:8E";
        address = "10.10.1.168";
        appId = 881448767;
        resolution = "3840x2160@60";
      }];
    };
    "systemd/user/app-dev.lizardbyte.app.Sunshine.service.d/capture.conf".text = ''
      [Unit]
      PartOf=graphical-session.target
      [Service]
      Slice=session-graphical.slice
      ExecStartPre=
      ExecStart=
      ExecStart=/usr/bin/sunshine capture=wlr
      ExecStopPost=/usr/bin/python3 ${../../modules/home/desktop/airplay/resolution.py}
    '';
    "pipewire/pipewire-pulse.conf.d/sunshine.conf".text = ''
      stream.rules = [{
        matches = [{ application.process.binary = "sunshine" media.class = "Stream/Input/Audio" }]
        actions = { update-props = { media.name = "Sunshine desktop audio" } }
      }]
    '';
    "autostart/com.onepassword.OnePassword.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=1Password
      Exec=/opt/1Password/1password --silent
    '';
  };

  systemd.user.services.xdg-home-cleaner =
    (import ../../modules/home/session-service.nix)
      "xdg-home-cleaner" ../../modules/home/desktop/session/xdg-home-cleaner.sh;
}
