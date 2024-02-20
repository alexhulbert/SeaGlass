#!/bin/bash
wpg-install.sh -ig
mkdir -p $HOME/.local/share/color-schemes
hyprpm add https://github.com/alexhulbert/HyprChroma
hyprpm enable Hypr-Chroma
