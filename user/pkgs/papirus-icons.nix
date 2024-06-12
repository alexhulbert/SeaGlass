{ pkgs }:

let 
  papirus-icon-theme = pkgs.fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "papirus-icon-theme";
    rev = "b4c51e297e9151289578f9b924c49a2b250a1d32";
    sha256 = "sha256-EAxNFfhLtOo7B9v0SYmpAA/RzRRARde3BjM8GGm39A0=";
  };
in pkgs.stdenv.mkDerivation {
  pname = "papirus-colors-icon-theme";
  version = "2023-05-28";

  src = pkgs.fetchFromGitHub {
    owner = "luisbocanegra";
    repo = "papirus-colors";
    rev = "0474c96a4eafcf76cc0d55501025375a51e495df";
    sha256 = "sha256-oY7PO7KLFwnqApEdWusL6+2freNArRhsoHayjjrNLW0=";
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  nativeBuildInputs = [ pkgs.bash ];

  buildPhase = ''
    # Replace "~/.local/share/icons/" with output directory
    sed -i "\
      s|#!/bin/bash|${pkgs.stdenv.shell}|g; \
      s|~/.local/share/icons/|$out/|g; \
      s|/bin/cp|cp|g
    " places_icons_mod.sh

    # Run the modified script
    mkdir $out
    ./places_icons_mod.sh 
  '';

  installPhase = ''
    # Create directories for the icon themes
    mkdir -p $out/Papirus-Colors-Dark
    mkdir -p $out/Papirus-Colors

    # Copy files from Papirus-Dark to Papirus-Colors-Dark
    cp -R --update=none ${papirus-icon-theme}/Papirus-Dark/* $out/Papirus-Colors-Dark/

    # Copy files from Papirus to Papirus-Colors
    cp -R --update=none ${papirus-icon-theme}/Papirus/* $out/Papirus-Colors/
  '';
}