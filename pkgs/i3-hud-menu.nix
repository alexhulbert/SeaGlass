{ pkgs, lib, python3Packages }:

with python3Packages;

buildPythonApplication rec {
  pname = "i3-hud-menu";
  version = "1.0.0";
  format = "other";

  src = pkgs.fetchurl {
    url = "https://github.com/nick87720z/i3-hud-menu/archive/refs/heads/fix-dmenu-result.tar.gz";
    sha256 = "05i419ry1nzzv7knirj87dg2lcicj55wzyzqbl4wfff65hwqyxgq";
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
    cp i3-hud-menu.py $out/bin/i3-hud-menu
    cp i3-appmenu-service.py $out/bin/i3-appmenu-service
    chmod +x $out/bin/i3-hud-menu
    
    gappsWrapperArgs+=(
      "--prefix" "PYTHONPATH" : "${makePythonPath propagatedBuildInputs}"
      "--set" "PYTHONNOUSERSITE" "1"
    )
  '';
}
