#!/bin/bash
wpg-install.sh -ig
mkdir -p $HOME/.local/share/color-schemes
hyprpm add https://github.com/alexhulbert/HyprChroma
hyprpm add https://github.com/DreamMaoMao/hycov
hyprpm enable Hypr-Chroma
hyprpm enable hycov
ln -s ~/.config/aconfmgr $(basename $(pwd))/system
ln -s ~/.config/home-manager $(basename $(pwd))/user
