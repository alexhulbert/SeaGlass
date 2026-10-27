{ config, lib, ... }: {
  seaglass.sessionUnits.hyprmoncfgd = "";

  services.pipewire = {
    enable = true;
    wireplumber = {
      enable = true;
      configs."60-monitor-priority"."monitor.alsa.rules" = [{
        matches = [{ "node.name" = "~alsa_output.*(HDMI|hdmi).*"; }];
        actions.update-props."priority.session" = 900;
      }];
    };
  };
  xdg.configFile."wireplumber" = {
    recursive = true;
    onChange = lib.mkForce ''
      if [[ ! -v oldGenPath ]] || ! diff -qr \
        "$oldGenPath/home-files/.config/wireplumber" \
        "$newGenPath/home-files/.config/wireplumber" >/dev/null 2>&1; then
        PIPEWIRE_RELOAD=1
      fi
    '';
  };
}
