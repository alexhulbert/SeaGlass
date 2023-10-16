{
  lib,
  config,
  pkgs,
  ...
}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  plasma-manager =
    (import flake-compat {
      src = builtins.fetchTarball "https://github.com/pjones/plasma-manager/archive/master.tar.gz";
    })
    .defaultNix;
in {
    imports = [
      # ./pkgs/i3-sidebar.nix
      ./i3.nix
      ./terminal.nix
      ./firefox.nix
      ./picom.nix
      ./plasma.nix
      ./theme.nix
      ./vscode.nix
      ./vim
      ./personal.nix
      plasma-manager.homeManagerModules.plasma-manager
    ];

    news.display = "silent";

    services.unclutter.enable = true;

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
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScriptBin "clean-nix-store" ''
          nix-store --gc
          nix-store --optimize
        ''}/bin/clean-nix-store";
      };
    };
}
