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
    path = "${./files/darkreader}/index.js";
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

  config.xdg.configFile."vimfx/config.js".source = ./files/vimfx.js;
  config.xdg.configFile."vimfx/frame.js".text = "";

  config.xdg.configFile."wal/templates/userContent.css".source = ./files/theme/firefox/userContent.css;

  config.programs.firefox = {
    enable = true;
    profileVersion = null;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "dom.w3c_touch_events.enabled" = 1;
        "widget.use-xdg-desktop-portal" = true;
        "apz.gtk.kinetic_scroll.enabled" = false;
      };
      userChrome = ''
        @import url('blurredfox/userChrome.css');
        @import url('userContent.css');
        @import url('twoline.css');
        @import url('oneline.css');
      '';
    };
  };

  config.outOfStoreSymlinks.home = {
    ".mozilla/firefox/default/chrome/userContent.css" = "${config.xdg.cacheHome}/wal/userContent.css";
  };

  config.home.file = {
    ".mozilla/firefox/default/chrome/twoline.css".source = ./files/theme/firefox/twoline.css;
  };
}
