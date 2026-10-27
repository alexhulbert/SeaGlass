{ lib, ... }: {
  xdg.configFile = lib.genAttrs [
    "systemd/user/pipewire.service.d/10-libcamera-mesa-egl.conf"
    "systemd/user/wireplumber.service.d/10-libcamera-mesa-egl.conf"
  ] (_: {
    text = ''
      [Service]
      Environment=__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
    '';
  });
}
