{ config
, pkgs
, lib
, ...
}:
let
  fxcast = pkgs.fx_cast_bridge.overrideAttrs (o: {
    version = "0.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "hensm";
      repo = "fx_cast";
      rev = "v0.3.1";
      hash = "sha256-hB4NVJW2exHoKsMp0CKzHerYgj8aR77rV+ZsCoWA1Dg=";
    };
  });

  darkreaderManifest = {
    name = "darkreader";
    description = "custom darkreader native host for syncing with pywal";
    path = "${./resources/darkreader}/index.js";
    type = "stdio";
  };
in
{
  config.xdg.configFile."google-chrome/NativeMessagingHosts/darkreader.json".text = builtins.toJSON
    (darkreaderManifest // { allowed_origins = [ "chrome-extension://gidgehhdgebooieidpcckaphjbfcghpe/" ]; });

  config.home.file = {
    ".mozilla/native-messaging-hosts/darkreader.json".text = builtins.toJSON
      (darkreaderManifest // { allowed_extensions = [ "darkreader@alexhulbert.com" ]; });
  };

  config.xdg.configFile."vimfx/config.js".source = ./resources/vimfx.js;
  config.xdg.configFile."vimfx/frame.js".text = "";

  config.xdg.configFile."wal/templates/userContent.css".source = ./resources/theme/firefox/userContent.css;

  config.programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "dom.w3c_touch_events.enabled" = 1;
        "widget.use-xdg-desktop-portal" = true;
        "apz.gtk.kinetic_scroll.enabled" = false;
      };
      userChrome = ''
        @import url('blurredfox/userChrome.css');
        @import url('userContent.css');
        @import url('layout.css');
      '';
    };
  };

  config.outOfStoreSymlinks.home = {
    ".mozilla/firefox/default/chrome/userContent.css" = "${config.xdg.cacheHome}/wal/userContent.css";
  };

  config.home.file = {
    ".mozilla/firefox/default/chrome/blurredfox".source = pkgs.fetchFromGitHub {
      owner = "manilarome";
      repo = "blurredfox";
      rev = "6976b5460f47bd28b4dc53bd093012780e6bfed3";
      sha256 = "0mj47pv27dv2bk4hsdjl3c81kw6bz9kk7gkdz30l4z88ckj31j0j";
    };

    ".mozilla/firefox/default/chrome/layout.css".source = ./resources/theme/firefox/twoline.css;
    ".mozilla/firefox/default/chrome/blur.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pavlukivan/dotfiles/6dfa74974cb25d9730a37bf4895a0f8421092b9e/firefox-transparency.css";
      sha256 = "0k1h14hpzm25sh7jrrxrgafrhld742gy0ybf74fz1n7s8w0fd1kn";
    };
  };
}
