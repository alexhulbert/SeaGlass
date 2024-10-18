#!/bin/bash
hyprpm add https://github.com/alexhulbert/Hyprchroma
# hyprpm add https://github.com/DreamMaoMao/hycov
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprchroma
# hyprpm enable hycov
hyprpm enable hyprexpo
ln -s ~/.config/aconfmgr $(basename $(pwd))/system
ln -s ~/.config/home-manager $(basename $(pwd))/user
activate-global-python-argcomplete
