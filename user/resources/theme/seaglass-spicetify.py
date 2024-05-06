#!/usr/bin/env python3

import os
import sys
import subprocess
import configparser

# Define the hard-coded color mapping
color_mapping = {
    "text": "ForegroundNormal",
    "subtext": "ForegroundInactive",
    "main": "BackgroundNormal",
    "sidebar": "BackgroundNormal",
    "player": "BackgroundNormal",
    "card": "BackgroundAlternate",
    "shadow": "BackgroundAlternate",
    "selected-row": "ForegroundNormal",
    "button": "ForegroundNormal",
    "button-active": "ForegroundNormal",
    "button-disabled": "ForegroundInactive",
    "tab-active": "ForegroundNormal",
    "notification": "BackgroundAlternate",
    "notification-error": "ForegroundNegative",
    "misc": "BackgroundNormal"
}

# Get the user's home directory
home_dir = os.path.expanduser("~")

# Read the sourcefile
sourcefile_path = os.path.join(home_dir, ".local", "share", "color-schemes", "MaterialYouDark.colors")
sourcefile = configparser.ConfigParser()
sourcefile.read(sourcefile_path)

# Create a new configparser for color.ini
colorfile = configparser.ConfigParser()
colorfile.add_section("pywal")

# Map the colors from sourcefile to color.ini
for key, value in color_mapping.items():
    color = sourcefile.get("Colors:View", value).replace("#", "")
    # If color has an alpha channel (#AARRGGBB), remove it
    if len(color) == 8:
        color = color[2:]
    colorfile.set("pywal", key, color)

# Path to the spicetify theme
colorfile_path = "/usr/share/spicetify-cli/Themes/Ziro/color.ini"

# Check if we have write access to colorfile_path
# If not, use sudo to give everyone write access
if not os.access(colorfile_path, os.W_OK):
    subprocess.run(["sudo", "chmod", "ugo+w", colorfile_path])

# Write the color.ini file
with open(colorfile_path, "w") as file:
    colorfile.write(file)

print(f"Color mapping completed. color.ini file generated at {colorfile_path}")

# Call spicetify apply to apply the new colors
os.system("spicetify apply") 
print("Spicetify theme applied.")
