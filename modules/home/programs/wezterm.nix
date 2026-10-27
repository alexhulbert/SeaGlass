{ link, ... }: {
  xdg.configFile."wezterm/wezterm.lua".source = link "modules/home/programs/wezterm.lua";
}
