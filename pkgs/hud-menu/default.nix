{ pkgs, lib, python3Packages }:

with python3Packages;

buildPythonApplication rec {
  pname = "i3-hud-menu";
  version = "1.0.0";
  format = "other";

  src = pkgs.fetchurl {
    url = "https://github.com/jamcnaughton/i3-hud-menu/archive/master.tar.gz";
    sha256 = "0pnvklwffawl6wnrsjd63wz38r0lc09kz9g7l1w0kjvac6xws5rg";
  };
  
  nativeBuildInputs = [
    pkgs.wrapGAppsHook
    pkgs.gobject-introspection
  ];
   
  strictDeps = false;

  propagatedBuildInputs = [
    pkgs.gtk3
    pkgs.dmenu
    dbus-python
    pygobject3
  ];

  doCheck = false;

  preInstall = ''
    echo "install: ;" > Makefile
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp hud-menu.py $out/bin/hud-menu
    cp hud-menu-service.py $out/bin/hud-menu-service
    chmod +x $out/bin/hud-menu
    
    gappsWrapperArgs+=(
      "--prefix" "PYTHONPATH" : "${makePythonPath propagatedBuildInputs}"
      "--set" "PYTHONNOUSERSITE" "1"
    )
  '';
}
