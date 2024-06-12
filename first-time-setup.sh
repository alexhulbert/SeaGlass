#!/bin/bash
hyprpm add https://github.com/alexhulbert/HyprChroma
hyprpm add https://github.com/DreamMaoMao/hycov
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable Hypr-Chroma
hyprpm enable hycov
hyprpm enable hyprexpo
ln -s ~/.config/aconfmgr $(basename $(pwd))/system
ln -s ~/.config/home-manager $(basename $(pwd))/user
