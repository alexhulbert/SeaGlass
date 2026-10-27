{ inputs, ... }: {
  imports = [
    inputs.wayhud.homeModules.default
    ./appearance.nix
    ./associations.nix
    ./airplay
    ./dms
    ./theme
    ./hyprland
    ./icons
    ./coloreader
    ./monitors.nix
    ./session
    ../programs/firefox
    ../programs/vscode
    ../programs/spotify
    ../programs/wezterm.nix
    ../programs/handy
  ];
  services.wayhud.enable = true;
}
