{ pkgs, lib, python3Packages }:

with python3Packages;

buildPythonApplication rec {
  pname = "pywalfox-native";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/Frewacom/pywalfox-native/archive/master.tar.gz";
    sha256 = "1wwbaxl0kya68w0f3bhhrfhja87agqz8gvyjdqcw96bsyhflaqgp";
  };
  
  nativeBuildInputs = [
    pkgs.wrapGAppsHook
  ];

  preInstall = ''
    mkdir -p "$out/lib/mozilla/native-messaging-hosts"
    cp pywalfox/assets/manifest.json "$out/lib/mozilla/native-messaging-hosts/"
  '';

  # postInstall = "chmod +x $out/bin/main.sh";
   
  doCheck = false;
}
