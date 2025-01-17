{ config
, pkgs
, lib
, ...
}:
let
  # fetch from github.com/alexhulbert/ulauncher-pywal-theme
  ulauncher-pywal-theme = pkgs.fetchFromGitHub {
    owner = "alexhulbert";
    repo = "pywal-ulauncher-theme";
    rev = "5d3c02354b0e468e9712dea283cfd10096486dba";
    sha256 = "sha256-DDaAnYnQAkJCJjYDCDrEds6NS62+h9cf5POLfxSvSBE=";
  };
in
{
  outOfStoreSymlinks.xdgConfig = {
    "ulauncher/user-themes/pywal-ulauncher-theme/template.css" =
      "${config.xdg.cacheHome}/wal/ulauncher.css";
  };

  mutableConfig.files = {
    "${config.xdg.configHome}/ulauncher/settings.json" = {
      "clear_previous_query" = true;
      "disable_desktop_filters" = false;
      "enable_application_mode" = true;
      "grab_mouse_pointer" = true;
      "max_recent_apps" = 0;
      "raise_if_started" = false;
      "render_on_screen" = "mouse-pointer-monitor";
      "show_indicator_icon" = false;
      "show_recent_apps" = "0";
      "close_on_focus_out" = false;
      "theme_name" = "Pywal-Ulauncher-Theme";
    };
  };

  xdg.configFile = {
    "wal/templates/ulauncher.css".source =
      "${ulauncher-pywal-theme}/pywal-ulauncher-themplate.css";
    "ulauncher/user-themes/pywal-ulauncher-theme/manifest.json".source =
      "${ulauncher-pywal-theme}/manifest.json";
    "ulauncher/user-themes/pywal-ulauncher-theme/theme.css".source =
      "${ulauncher-pywal-theme}/theme.css";
    "ulauncher/user-themes/pywal-ulauncher-theme/theme-gtk-3.20.css".source =
      "${ulauncher-pywal-theme}/theme-gtk-3.20.css";
  };
}
