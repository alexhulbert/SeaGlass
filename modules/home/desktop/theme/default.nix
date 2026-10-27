{ config, pkgs, lib, repoPath, link, ... }: let
  splashCarousel = pkgs.fetchFromGitHub {
    owner = "alexhulbert-ai";
    repo = "splash-carousel";
    rev = "8dd4aab50e5ee32ddcd6c57d047eab7591d8d38d";
    hash = "sha256-oQTmVcMhtvNBx4xn0GiV94RP4aCNyfR2Wvwrs5c9hDY=";
  };
in {
  options.seaglass.matugen = lib.mkOption {
    type = (pkgs.formats.toml {}).type;
    default = {};
    description = "Shared Matugen configuration and templates.";
  };

  config = {
    xdg.configFile."matugen/config.toml".source =
      (pkgs.formats.toml {}).generate "matugen.toml" config.seaglass.matugen;
    seaglass.matugen.config = {};

    home.file.".local/bin/matugen".source = link "modules/home/desktop/theme/matugen-canvas.py";
    seaglass.dmsPlugins.seaglassCanvas = "${repoPath}/modules/home/desktop/theme/canvas";
    seaglass.dmsPlugins.wallhavenCarousel = "${splashCarousel}";
    seaglass.sessionUnits.dms = lib.mkAfter ''
      ExecStartPre=-/usr/bin/python3 ${splashCarousel}/wallpaper.py startup
    '';
    seaglass.dmsPlugins.seaglassWallpaper = "${repoPath}/modules/home/desktop/theme/wallpaper";
    seaglass.jsonSettings."${config.xdg.configHome}/DankMaterialShell/plugin_settings.json".seaglassWallpaper.enabled = true;
  };
}
