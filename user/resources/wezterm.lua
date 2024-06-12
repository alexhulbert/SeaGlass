local wezterm = require 'wezterm'

local home = wezterm.home_dir
local wal_scheme = home .. "/.cache/wal/wezterm-wal.toml"
wezterm.add_to_config_reload_watch_list(wal_scheme)

return {
  check_for_updates = false,
  tab_bar_at_bottom = true,
  warn_about_missing_glyphs = false,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  show_new_tab_button_in_tab_bar = false,
  font = wezterm.font 'Fira Code Nerd Font Mono',
  color_scheme_dirs = { home .. "/.cache/wal" },
  color_scheme = 'wezterm-wal',
  window_padding = {
    left = 42,
    right = 42,
    top = 36,
    bottom = 36,
  },
  keys = {
    {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
        local sel = window:get_selection_text_for_pane(pane)
        if (not sel or sel == '') then
          window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
        else
          window:perform_action(wezterm.action{ CopyTo = 'ClipboardAndPrimarySelection' }, pane)
        end
      end),
    },
    { key = 'v', mods = 'CTRL', action = wezterm.action{ PasteFrom = 'Clipboard' } },
  }
}
