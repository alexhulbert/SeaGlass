{ config, pkgs, ... }:
let 
  pinned-firefox = import (builtins.fetchTarball {
   name = "pinned-firefox-nixpkgs";
    url = "https://github.com/nixos/nixpkgs/archive/657b329f83519c9205a0f41f6a266890e291d7a1.tar.gz";
    sha256 = "1gj0mysd6q461ny13cpdclnvqh7f11zrzyr83234mi6vkjw5vdqw";
  }) {};
in {
  config.home.file = {
    ".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
    ".mozilla/native-messaging-hosts/darkreader.json".text = builtins.toJSON {
      name = "darkreader";
      description = "custom darkreader native host for syncing with pywal";
      path = "/etc/nixos/resources/darkreader/index.js";
      type = "stdio";
      allowed_extensions = [ "darkreader@alexhulbert.com" ];
    };
  };

  config.programs.firefox = {
    enable = true;
    package = pinned-firefox.firefox-esr-91-unwrapped;
    profiles.default = {
      id = 0;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "svg.context-properties.content.enabled" = true;
        "layout.css.backdrop-filter.enabled" = true;
        "dom.w3c_touch_events.enabled" = 1;
        "widget.use-xdg-desktop-portal" = true;
      };
      userChrome = ''
        @import url('blurredfox/userChrome.css');
        @import url('userContent.css');
        @import url('oneline.css');
      '';
    };
    profiles.ssb = {
      id = 1;
      settings = config.programs.firefox.profiles.default.settings;
      userChrome = ''
        @import url('blurredfox/userChrome.css');
        @import url('userContent.css');
        @import url('nochrome.css');
      '';
    };
  };

  config.home.file = {
    ".mozilla/firefox/default/chrome/blurredfox".source = pkgs.fetchFromGitHub {
      owner = "manilarome";
      repo = "blurredfox";
      rev = "6976b5460f47bd28b4dc53bd093012780e6bfed3";
      sha256 = "0mj47pv27dv2bk4hsdjl3c81kw6bz9kk7gkdz30l4z88ckj31j0j";
    };

    ".mozilla/firefox/default/chrome/oneline.css".source = ./resources/theme/oneline.css;
    ".mozilla/firefox/default/chrome/blur.css".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/pavlukivan/dotfiles/6dfa74974cb25d9730a37bf4895a0f8421092b9e/firefox-transparency.css";
      sha256 = "0k1h14hpzm25sh7jrrxrgafrhld742gy0ybf74fz1n7s8w0fd1kn";
    };

    ".mozilla/firefox/ssb/chrome/nochrome.css".source = ./resources/theme/nochrome.css;
    ".mozilla/firefox/ssb/chrome/blurredfox" = {
      source = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/blurredfox";
      recursive = true;
    };
    ".mozilla/firefox/ssb/chrome/blur.css" = {
      source = "${config.home.homeDirectory}/.mozilla/firefox/default/chrome/blur.css";
      recursive = true;
    };
  };
}