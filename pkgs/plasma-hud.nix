{ lib, python3, fetchFromGitHub, rofi, gobject-introspection, wrapGAppsHook, pango, gtk3 }:

python3.pkgs.buildPythonApplication rec{
  pname = "plasma-hud";
  version = "19.10.1";

  src = fetchFromGitHub {
    owner = "Zren";
    repo = pname;
    rev = version;
    sha256 = "19vlc156jfdamw7q1pc78fmlf0h3sff5ar3di9j316vbb60js16l";
  };

  buildInputs = [
    gtk3
    pango
  ];

  propagatedBuildInputs = with python3.pkgs; [
    rofi
    dbus-python
    setproctitle
    xlib
    pygobject3
    gobject-introspection
  ];
  format = "other";
  postPatch = ''
    sed -i "s:/usr/lib/plasma-hud:$out/bin:" etc/xdg/autostart/plasma-hud.desktop
  '';

  installPhase = ''
    patchShebangs $out/bin/plasma-hud
    mkdir -p $out/bin $out/etc/xdg/autostart
    cp -r $src/usr/lib/plasma-hud/plasma-hud $out/bin/plasma-hud
    cp -r $src/etc $out/etc
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook
  ];

  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out $propagatedBuildInputs"
  '';

  strictDeps = false;

  # Produce only one wrapper using wrap-python passing
  # gappsWrapperArgs to wrap-python additional wrapper
  # argument
  dontWrapGApps = true;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = with lib;{
    license = licenses.gpl2Only;
    homepage = "https://github.com/Zren/plasma-hud";
    platforms = platforms.unix;
    description = "Run menubar commands, much like the Unity 7 Heads-Up Display (HUD)";
    maintainers = with maintainers; [ pasqui23 ];
  };
}
