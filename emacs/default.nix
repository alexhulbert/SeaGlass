{ pkgs, ... }:

let
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
  }) {
    doomPrivateDir = ./.;
  };
in {
  home.packages = [ pkgs.emacs-nox ];
  home.sessionVariables.EDITOR = "emacsclient -c -nw";
  services.emacs = {
    enable = true;
    package = doom-emacs;
  };
}
