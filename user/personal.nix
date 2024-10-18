{
  config,
  pkgs,
  lib,
  ...
}: let
  shim = import ./pkgs/shim.nix { inherit pkgs; };
in {
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  programs.git = {
    enable = true;
    package = shim {
      name = "git";
      cmds = ["git"];
    };
    userName = "alexhulbert";
    userEmail = "alex@alexhulbert.com";
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

  home.file.".mozilla/firefox/default/chrome/layout.css".source =
    lib.mkForce ./files/theme/firefox/oneline.css;

}
