{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
  gpgKey = "54F7B202E38A7ED2";
in {
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  programs.gpg = {
    enable = true;
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
    enable = true;
    package = shim {
      name = "git";
      cmds = ["git"];
    };
    settings.user.name = "alexhulbert";
    settings.user.email = "alex@alexhulbert.com";
    signing = {
      key = gpgKey;
      signByDefault = true;
    };
  };

  # shorter names for ~ subdirs
  xdg.userDirs = {
    desktop = "${config.home.homeDirectory}/tmp";
    download = "${config.home.homeDirectory}/tmp";
    documents = "${config.home.homeDirectory}/files";
    music = "${config.home.homeDirectory}/files/media";
    pictures = "${config.home.homeDirectory}/files/media";
    videos = "${config. home.homeDirectory}/files/media";
  };

  home.file = {
    ".mozilla/firefox/default/chrome/oneline.css".source = ./files/theme/firefox/oneline.css;
  };

}
