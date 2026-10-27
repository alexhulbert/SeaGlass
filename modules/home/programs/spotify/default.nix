{ config, pkgs, lib, link, ... }: {
  home.packages = [ (pkgs.callPackage ./package.nix {}) ];
  xdg.configFile."spotify-flags.conf".text = "--ozone-platform=wayland\n";

  home.activation.spicetify = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    run ${config.home.profileDirectory}/bin/spicetify daemon install
    run /usr/bin/systemctl --user restart spicetify-daemon
  '';
  xdg.mimeApps.defaultApplications."x-scheme-handler/spicetify" = "spicetify-protocol.desktop";

  xdg.configFile."spicetify/modules/ziro".source = pkgs.fetchzip {
    url = "https://github.com/spicetify/modules/releases/download/ziro@0.1.6/ziro@0.1.6.zip";
    stripRoot = false;
    hash = "sha256-mKWcrUE57OuhplHLUPQ3FqU7pCX/93BxTQPFzURvy/k=";
  };
  xdg.configFile."spicetify/config.toml".source = (pkgs.formats.toml {}).generate "spicetify.toml" {
    spotify_data_dir = "/opt/spotify";
    spotify_exec = "/usr/bin/spotify";
    auto_update = false;
  };
  xdg.configFile."spicetify/modules/coloreader".source = link "modules/home/programs/spotify/coloreader";

  services.coloreader.allowedOrigins = [ "https://xpui.app.spotify.com" ];
}
