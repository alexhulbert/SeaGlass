{ config, lib, repoPath, link, ... }: let
in {
  home.file = {
    ".mozilla/firefox/default/chrome/userChrome.css".text = lib.mkDefault ''@import url("shared.css");'';
    ".mozilla/firefox/default/chrome/shared.css".source = link "modules/home/programs/firefox/userChrome.css";
    ".local/bin/firefox".source = link "modules/home/programs/firefox/firefox-smart";
  };
  home.activation.firefoxDesktop = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run sed 's|/usr/lib/firefox/firefox|${config.home.homeDirectory}/.local/bin/firefox|g' /usr/share/applications/firefox.desktop > ${lib.escapeShellArg "${config.xdg.dataHome}/applications/firefox.desktop"}
  '';

  seaglass.matugen.templates.firefox = {
    input_path = "${repoPath}/modules/home/programs/firefox/colors.css";
    output_path = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/colors.css";
  };
  programs.firefox = {
    enable = true;
    package = null;
    profileVersion = null;
    configPath = "${config.home.homeDirectory}/.mozilla/firefox";
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.startup.page" = 1;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layout.css.prefers-color-scheme.content-override" = 3;
        "dom.w3c_touch_events.enabled" = 1;
        "widget.use-xdg-desktop-portal" = true;
        "apz.gtk.kinetic_scroll.enabled" = false;
        "widget.gtk.global-menu.enabled" = true;
      };
      userContent = ''@import url("colors.css");'';
    };
  };
}
