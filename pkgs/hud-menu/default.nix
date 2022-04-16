{ pkgs, lib, python3Packages }:

with python3Packages;

buildPythonApplication rec {
  pname = "i3-hud-menu";
  version = "1.0.0";
  format = "other";

  src = pkgs.fetchurl {
    url = "https://github.com/alexhulbert/hud-menu/archive/master.tar.gz";
    sha256 = "0z73fayvl8l2jvrcc9hg6g2292xg0l5j7dwi35vii4hj0sg8kaj6";
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
