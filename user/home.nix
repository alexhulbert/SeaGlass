{ lib
, config
, pkgs
, ...
}:
let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  nix-index-database =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/nix-community/nix-index-database/archive/refs/tags/2024-03-17-030743.zip";
    }).defaultNix;
in
{
  imports = [
    ./hyprland.nix
    ./terminal.nix
    ./firefox.nix
    ./plasma.nix
    ./startup.nix
    ./waybar.nix
    ./vscode.nix
    ./ulauncher.nix
    ./vim
    ./personal.nix
    ./pkgs/symlink.nix
    ./pkgs/mutable-config.nix
    nix-index-database.hmModules.nix-index
  ];

  news.display = "silent";

  home.packages = lib.mkForce (with config.programs; [
    neovim.finalPackage
    starship.package
    pkgs.home-manager
    pkgs.comma
  ]);

  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  systemd.user.services.cleanup = {
    Unit.Description = "Clean and optimize Nix store on boot";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScriptBin "clean-nix-store" ''
          nix-store --gc
          nix-store --optimize
        ''}/bin/clean-nix-store";
    };
  };
}
