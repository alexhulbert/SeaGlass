{ config, pkgs, lib, ... }: {
  config.xdg.configFile = {
    "systemd/user/plasma-kwin_x11.service".source = config.lib.file.mkOutOfStoreSymlink "/dev/null";
    "systemd/user/plasma-workspace-x11.target.wants/i3.service".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/systemd/user/i3.service";
  };
  config.xsession.windowManager.i3 = {
    enable = true;
    config = {
      bars = [];
      gaps = {
        inner = 15;
        outer = 0;
      };
      modifier = "Mod4";
      terminal = "konsole";
      keycodebindings = {
        "66" = "workspace back_and_forth";
        "Control+66" = "exec --no-startup-id xdotool key Caps_Lock";
      };
      keybindings = let modifier = config.xsession.windowManager.i3.config.modifier; in lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+w" = "exec firefox";
        "${modifier}+Shift+q" = "exec --no-startup-id xdotool getwindowfocus windowkill";
        "${modifier}+e" = "exec --no-startup-id \"qdbus com.github.zren.PlasmaHUD /PlasmaHUD toggleHUD\"";
        "${modifier}+d" = "exec --no-startup-id albert show";
        # "${modifier}+Shift+a" = "exec --no-startup-id \"i3-sidebar Todoist left 0.3 'firefox -P ssb --new-window https://todoist.com'\"";
        # "${modifier}+Shift+w" = "exec --no-startup-id \"i3-sidebar Spotify top 0.66 spotify\"";
        # "${modifier}+Shift+d" = "exec --no-startup-id \"i3-sidebar Messenger right 0.4 'firefox -P ssb --new-window https://messenger.com'\"";
        # "${modifier}+Shift+s" = "exec --no-startup-id \"i3-sidebar Konsole bottom 0.5 konsole\"";
        # "${modifier}+Shift+e" = "exec --no-startup-id \"i3-sidebar Slack top 0.66 'firefox -P ssb --new-window https://radix-labs.slack.com/ssb/redirect'\"";
      };
    };
    extraConfig = ''
      bindcode --release Shift+122 exec --no-startup-id xdotool key --clearmodifiers XF86AudioPrev
      bindcode --release Shift+123 exec --no-startup-id xdotool key --clearmodifiers XF86AudioNext
      for_window [class="^.*"] border pixel 0
      for_window [title="Desktop — Plasma"] kill; floating enable; border none
      for_window [title="Desktop @ QRect"] kill
      for_window [title="win0"] floating enable
      for_window [title="Picture-in-Picture"] sticky enable
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="task_dialog"] floating enable
      for_window [class="plasmashell"] floating enable
      for_window [class="Plasma"] floating enable; border none
      for_window [title="plasma-desktop"] floating enable; border none
      for_window [class="Plasmoidviewer"] floating enable; border none
      for_window [class="plasmashell" window_type="notification"] border none, move right 1400px, move down 900px
      no_focus [class="plasmashell" window_type="notification"]
      exec --no-startup-id i3-msg workspace 2
      exec --no-startup-id i3-msg workspace 1
      exec --no-startup-id xsettingsd
      exec --no-startup-id alternating_layouts.py
    '';
  };
}
