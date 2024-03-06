{
  lib,
  config,
  pkgs,
  ...
}: {
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
